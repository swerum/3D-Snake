using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Snake : MonoBehaviour
{
    [SerializeField] Vector2Int startingDirection = Vector2Int.down;
    [SerializeField] Vector2Int fieldSize = new Vector2Int(10, 10);
    [SerializeField] Vector2Int startingPosition;
    [SerializeField] float speed = 1;
    [SerializeField] GameObject block;
    [SerializeField] GameObject floorCube;

    private float tickTime;
    private Vector2Int direction;
    private float time = 0f;
    private float blockSize;
    private List<GameObject> bodySegments = new List<GameObject>();

    // Start is called before the first frame update
    void Start()
    {
        // set up starting variables
        tickTime = 1.0f / speed;
        blockSize = block.transform.localScale.x;
        direction = startingDirection;
        // set up floor
        float floorX = (fieldSize.x - 1) / 2.0f * blockSize;
        float floorY = (fieldSize.y - 1) / 2.0f * blockSize;
        floorCube.transform.position = new Vector3(floorX, -blockSize / 2f, floorY);
        floorCube.transform.localScale = new Vector3(fieldSize.x, 0.1f, fieldSize.y);
        /** create body of size one */
        for (int i = 0; i < 3; i++)
        {
            GameObject body = Instantiate(block);
            bodySegments.Add(body);
            body.transform.localPosition = new Vector3(startingPosition.x * blockSize, 0, startingPosition.y * blockSize);
        }
    }

    // Update is called once per frame
    void Update()
    {
        //check input
        direction = GetNewDirection();
        //move snake
        time += Time.deltaTime;
        if (time > tickTime)
        {
            time -= tickTime;
            OnTick();
        }
    }

    void OnTick()
    {
        Vector3 headPosition = bodySegments[0].transform.localPosition;
        Vector3 movement = new Vector3(direction.x, 0, direction.y) * blockSize;
        GameObject tail = PopTail();
        tail.transform.localPosition = headPosition + movement;
        bodySegments.Insert(0, tail);
    }

    private GameObject PopTail()
    {
        int tailIndex = bodySegments.Count == 0 ? 0 : bodySegments.Count - 1;
        GameObject tail = bodySegments[tailIndex];
        bodySegments.RemoveAt(tailIndex);
        return tail;
    }

    private Vector2Int GetNewDirection()
    {
        float horizontal = Input.GetAxis("Horizontal");
        if (horizontal != 0)
        {
            if (horizontal < 0) return Vector2Int.left;
            else return Vector2Int.right;
        }
        float vertical = Input.GetAxis("Vertical");
        if (vertical != 0)
        {
            if (vertical < 0) return Vector2Int.down;
            else return Vector2Int.up;
        }
        return direction;
    }
}
