using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SetToonLightDirection : MonoBehaviour
{
    [SerializeField] bool updateDirectionContinuously = true;
    [SerializeField] Material[] materials;
    [SerializeField] Vector3 scenePosition;

    // Start is called before the first frame update
    void Start()
    {
        SetLightDirections();
    }

    private void Update()
    {
        if (updateDirectionContinuously) SetLightDirections();
    }

    private void SetLightDirections()
    {
        Vector3 lightPos = gameObject.transform.position;
        Vector3 lightDirection = scenePosition - lightPos;
        Vector4 lightDirection4 = new Vector4(lightDirection.x, lightDirection.y, lightDirection.z, 0);
        foreach (Material m in materials)
        {
            int shaderId = Shader.PropertyToID("_LightDirection");
            m.SetVector(shaderId, lightDirection4);
        }

    }
}
