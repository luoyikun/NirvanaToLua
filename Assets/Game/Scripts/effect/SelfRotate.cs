using UnityEngine;
using System.Collections;

public class SelfRotate : MonoBehaviour {
	public float x;
	public float y;
	public float z;

	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
		this.gameObject.transform.Rotate (new Vector3(x*Time.deltaTime,y*Time.deltaTime,z*Time.deltaTime));
	
	}
}
