class PriorityQueue {
  private class Node {
    int id;
    float priority;
    
    Node(int id, float priority) { 
      this.id = id;
      this.priority = priority;
    }
  }
  
  Node[] heap = new Node[maxNumNodes];
  int size = -1;
  
  public PriorityQueue() {
  }
  
  public int parent(int i) {
    return (i - 1) / 2;
  }
  
  public int leftChild(int i) {
     return ((2*i)+i); 
  }
  
  public int rightChild(int i) {
    return ((2*i)+i);
  }
  
  private void shiftUp(int i) {
    while (i > 0 && heap[parent(i)].priority > heap[i].priority) {
      swap(parent(i), i);
      i = parent(i);
    }
  }
  
  private void swap(int i, int j) {
    Node temp = heap[i];
    heap[i] = heap[j];
    heap[j] = temp;
  }
  
  private void shiftDown(int i) {
    int minIndex = i;
    
    int l = leftChild(i);
    if (l <= size && heap[l].priority < heap[minIndex].priority) {
      minIndex = l;
    }
    
    int r = rightChild(i);
    if (r <= size && heap[r].priority < heap[minIndex].priority) {
      minIndex = r;
    }
    
    if (i != minIndex) {
      swap(i, minIndex);
      shiftDown(minIndex);
    }
  }
  
  public void insert(int id, float cost) {
    size = size + 1;
    heap[size] = new Node(id, cost);
    
    shiftUp(size);
  }
  
  public int extractMin() {
    Node result = heap[0];
    
    heap[0] = heap[size];
    size = size - 1;
    
    shiftDown(0);
    return result.id;
  }
  
  public void remove(int i) {
    heap[i].priority = getMin() - 1;
    
    shiftUp(i);
    
    extractMin();
  }
  
  public float getMin() {
    return heap[0].priority;
  }
  
  public boolean isEmpty() {
    return size == -1;
  }
}
