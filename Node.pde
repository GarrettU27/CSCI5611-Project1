class Node implements Comparable<Node> {
  public int id;
  public float priority;
  
  public Node(int id, float priority) {
    this.id = id;
    this.priority = priority;
  }
  
  public int compareTo(Node anotherNode) {
    if (this.id == anotherNode.id) {
      return 0;
    }
    else if (this.priority < anotherNode.priority) {
      return -1;
    }
    else if (this.priority > anotherNode.priority) {
      return 1;
    }
    else {
      return 1;
    }
  }
}
