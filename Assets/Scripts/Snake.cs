using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using Unity.Mathematics;
using UnityEngine;

public class Snake : MonoBehaviour
{
    [SerializeField] Vector2Int startingDirection = Vector2Int.up;
    [SerializeField] Vector2Int fieldSize = new Vector2Int(10, 10);
    [SerializeField] Vector2Int startingPosition;
    [SerializeField] float speed = 1;
    [SerializeField] GameObject bodySegmentPrefab;
    [SerializeField] GameObject foodPrefab;
    [SerializeField] GameObject floorCube;
    [SerializeField] TextMeshProUGUI gameOverText;

    private List<GameObject> bodySegments = new List<GameObject>();
    private List<Vector2Int> bodySegmentLocations = new List<Vector2Int>();
    private GameObject currentFood;
    private Vector2Int foodCoords;
    private Vector2Int direction;
    private float tickTime;
    private float time = 0f;
    private float blockSize;
    private bool gameOver;

    // Start is called before the first frame update
    void Start()
    {
        // set up starting variables
        tickTime = 1.0f / speed;
        blockSize = bodySegmentPrefab.transform.localScale.x;
        direction = startingDirection;
        gameOverText.text = "";
        // set up floor
        float floorX = (fieldSize.x - 1) / 2.0f * blockSize;
        float floorY = (fieldSize.y - 1) / 2.0f * blockSize;
        floorCube.transform.position = new Vector3(floorX, -blockSize / 2f - 1, floorY);
        floorCube.transform.localScale = new Vector3(fieldSize.x, 1f, fieldSize.y);
        /** create body of size one */
        for (int i = 0; i < 3; i++)
        {
            CreateBodySegment(startingPosition);
        }
        CreateFood();
    }

    // Update is called once per frame
    void Update()
    {
        if (gameOver) return;
        //check input
        Vector2Int newDirection = GetDirectionFromInput();
        if (newDirection != direction * -1) { direction = newDirection; }
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
        // Pop tail 
        int tailIndex = bodySegments.Count == 0 ? 0 : bodySegments.Count - 1;
        GameObject tail = bodySegments[tailIndex];
        bodySegments.RemoveAt(tailIndex);
        bodySegmentLocations.RemoveAt(tailIndex);
        // make tail the new head
        Vector2Int headCoords = bodySegmentLocations[0] + direction;
        gameOver = bodySegmentLocations.Contains(headCoords);
        if (headCoords.x < 0 || headCoords.y < 0 || headCoords.x >= fieldSize.x
            || headCoords.y >= fieldSize.y) { gameOver = true; }
        tail.transform.position = CoordsToWorldPosition(headCoords);
        bodySegments.Insert(0, tail);
        bodySegmentLocations.Insert(0, headCoords);
        if (gameOver)
        {
            gameOverText.text = "GAME OVER\nMax Length: " + bodySegmentLocations.Count;
        }
        // check for food
        if (headCoords == foodCoords) { EatFood(); }

    }

    private void CreateBodySegment(Vector2Int coords)
    {
        GameObject body = Instantiate(bodySegmentPrefab, transform);
        Debug.Assert(bodySegments.Count == bodySegmentLocations.Count);
        bodySegments.Insert(bodySegments.Count, body);
        bodySegmentLocations.Insert(bodySegmentLocations.Count, coords);
        body.transform.position = CoordsToWorldPosition(coords);
    }
    private void CreateFood()
    {
        foodCoords = GetRandomCoords();
        while (bodySegmentLocations.Contains(foodCoords)) { foodCoords = GetRandomCoords(); }
        currentFood = Instantiate(foodPrefab);
        currentFood.transform.position = CoordsToWorldPosition(foodCoords);

        Vector2Int GetRandomCoords()
        {
            float x = UnityEngine.Random.Range(0, fieldSize.x);
            float y = UnityEngine.Random.Range(0, fieldSize.y);
            Vector2Int r = new Vector2Int(Mathf.FloorToInt(x), Mathf.FloorToInt(y));
            return r;
        }
    }

    private void EatFood()
    {
        Destroy(currentFood);
        CreateBodySegment(foodCoords);
        CreateFood();
    }

    private Vector2Int GetDirectionFromInput()
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
    private Vector3 CoordsToWorldPosition(Vector2Int coords)
    {
        return new Vector3(coords.x * blockSize, 0, coords.y * blockSize);
    }
}
