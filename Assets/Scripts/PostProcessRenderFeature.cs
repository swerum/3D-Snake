using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class PostProcessRenderFeature : ScriptableRendererFeature
{
    [System.Serializable]
    public class CustomRenderPassSettings
    {
        public Material material;
        public RenderPassEvent renderPassEvent = RenderPassEvent.AfterRenderingPostProcessing;
    }

    PostProcessRenderPass renderPass;

    public CustomRenderPassSettings settings = new CustomRenderPassSettings();

    /// <inheritdoc/>
    /// 
    public override void Create()
    {
        renderPass = new PostProcessRenderPass(settings);
    }

    // Here you can inject one or multiple render passes in the renderer.
    // This method is called when setting up the renderer once per-camera.

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        // we dont wan't to run the pass if there is no material
        if (settings.material == null)
        {
            Debug.LogError("Render Pass `PostProcessRenderPassFeature` missing material");
            return;
        }

        //RenderTargetIdentifier source = renderer.cameraColorTarget;
        //m_ScriptablePass.Setup(source);
        if (renderingData.cameraData.cameraType == CameraType.Game)
            renderer.EnqueuePass(renderPass);
    }

    public override void SetupRenderPasses(ScriptableRenderer renderer, in RenderingData renderingData)
    {
        if (renderingData.cameraData.cameraType == CameraType.Game)
        {
            // Calling ConfigureInput with the ScriptableRenderPassInput.Color argument
            // ensures that the opaque texture is available to the Render Pass.
            renderPass.ConfigureInput(ScriptableRenderPassInput.Color | ScriptableRenderPassInput.Depth | ScriptableRenderPassInput.Normal | ScriptableRenderPassInput.Motion);
            renderPass.SetTarget(renderer.cameraColorTargetHandle);
        }
    }

    class PostProcessRenderPass : ScriptableRenderPass
    {
        RTHandle m_CameraColorTarget;

        // store settings instead of material itself
        PostProcessRenderFeature.CustomRenderPassSettings settings;

        // name this what you want, it will be used to name the profile in frame debugger
        const string profilingName = "SpeedLineRender-Pass";


        public PostProcessRenderPass(PostProcessRenderFeature.CustomRenderPassSettings settings)
        {
            // storing the settings allows you to add more features faster without having to boiler plate code,
            // also ensures that any changes made in the render feature reflect in the pass
            this.settings = settings;
            renderPassEvent = settings.renderPassEvent;

            // create a new profiling sampler with are chosen name,
            // else you get just a generic "ScriptableRendererPass" name
            this.profilingSampler = new ProfilingSampler(profilingName);
        }

        public void SetTarget(RTHandle colorHandle)
        {
            // get the source target from rendering data every frame
            m_CameraColorTarget = colorHandle;
        }

        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            ConfigureTarget(m_CameraColorTarget);
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            var cameraData = renderingData.cameraData;
            if (cameraData.camera.cameraType != CameraType.Game)
                return;

            CommandBuffer cmd = CommandBufferPool.Get(nameof(PostProcessRenderPass));
            using (new ProfilingScope(cmd, profilingSampler))
            {
                Blitter.BlitCameraTexture(cmd, m_CameraColorTarget, m_CameraColorTarget, settings.material, 0);
            }
            context.ExecuteCommandBuffer(cmd);
            cmd.Clear();

            CommandBufferPool.Release(cmd);
        }
    }
}