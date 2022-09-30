import java.util.*;
//You will only be turning in this file
//Your solution will be graded based on it's runtime (smaller is better), 
//the optimality of the path you return (shorter is better), and the
//number of collisions along the path (it should be 0 in all cases).

//You must provide a function with the following prototype:
// ArrayList<Integer> planPath(Vec2 startPos, Vec2 goalPos, Vec2[] centers, float[] radii, int numObstacles, Vec2[] nodePos, int numNodes);
// Where: 
//    -startPos and goalPos are 2D start and goal positions
//    -centers and radii are arrays specifying the center and radius of obstacles
//    -numObstacles specifies the number of obstacles
//    -nodePos is an array specifying the 2D position of roadmap nodes
//    -numNodes specifies the number of nodes in the PRM
// The function should return an ArrayList of node IDs (indexes into the nodePos array).
// This should provide a collision-free chain of direct paths from the start position
// to the position of each node, and finally to the goal position.
// If there is no collision-free path between the start and goal, return an ArrayList with
// the 0'th element of "-1".

// Your code can safely make the following assumptions:
//   - The function connectNeighbors() will always be called before planPath()
//   - The variable maxNumNodes has been defined as a large static int, and it will
//     always be bigger than the numNodes variable passed into planPath()
//   - None of the positions in the nodePos array will ever be inside an obstacle
//   - The start and the goal position will never be inside an obstacle

// There are many useful functions in CollisionLibrary.pde and Vec2.pde
// which you can draw on in your implementation. Please add any additional 
// functionality you need to this file (PRM.pde) for compatabilty reasons.

// Here we provide a simple PRM implementation to get you started.
// Be warned, this version has several important limitations.
// For example, it uses BFS which will not provide the shortest path.
// Also, it (wrongly) assumes the nodes closest to the start and goal
// are the best nodes to start/end on your path on. Be sure to fix 
// these and other issues as you work on this assignment. This file is
// intended to illustrate the basic set-up for the assignmtent, don't assume 
// this example funcationality is correct and end up copying it's mistakes!).



//Here, we represent our graph structure as a neighbor list
//You can use any graph representation you like
ArrayList<Integer>[] neighbors = new ArrayList[maxNumNodes];  //A list of neighbors can can be reached from a given node
//We also want some help arrays to keep track of some information about nodes we've visited
Boolean[] visited = new Boolean[maxNumNodes]; //A list which store if a given node has been visited
int[] parent = new int[maxNumNodes]; //A list which stores the best previous node on the optimal path to reach this node

//Set which nodes are connected to which neighbors (graph edges) based on PRM rules
void connectNeighbors(Vec2[] centers, float[] radii, int numObstacles, Vec2[] nodePos, int numNodes){
  for (int i = 0; i < numNodes; i++){
    neighbors[i] = new ArrayList<Integer>();  //Clear neighbors list
    for (int j = 0; j < numNodes; j++){
      if (i == j) continue; //don't connect to myself 
      Vec2 dir = nodePos[j].minus(nodePos[i]).normalized();
      float distBetween = nodePos[i].distanceTo(nodePos[j]);
      hitInfo circleListCheck = rayCircleListIntersect(centers, radii, numObstacles, nodePos[i], dir, distBetween);
      if (!circleListCheck.hit){
        neighbors[i].add(j);
      }
    }
  }
}

ArrayList<Integer> planPath(Vec2 startPos, Vec2 goalPos, Vec2[] centers, float[] radii, int numObstacles, Vec2[] nodePos, int numNodes){
  ArrayList<Integer> path = new ArrayList();
  
  path = runAStar(nodePos, numNodes, startPos, goalPos, centers, radii);
  
  return path;
}

// DOES NOT WORK YET. Still need to account for last bit
ArrayList<Integer> runAStar(Vec2[] nodePos, int numNodes, Vec2 startPos, Vec2 goalPos, Vec2[] centers, float[] radii) {
  int startID = numNodes + 1;
  int goalID = numNodes + 2;
  
  PriorityQueue<Node> fringe = new PriorityQueue<Node>(maxNumNodes);
  int[] cameFrom = new int[numNodes + 3];
  HashMap<Integer, Float> costSoFar = new HashMap<Integer, Float>();
  ArrayList<Integer> goalNodes = new ArrayList<Integer>();
  
  
  for (int i = 0; i < numNodes; i++){
    // put all nodes that can connect to startPos on the fringe
    Vec2 dir = nodePos[i].minus(startPos).normalized();
    float distBetween = startPos.distanceTo(nodePos[i]);
    hitInfo circleListCheck = rayCircleListIntersect(centers, radii, numObstacles, startPos, dir, distBetween);
    if (!circleListCheck.hit){
      fringe.add(new Node(i, distBetween + nodePos[i].distanceTo(goalPos)));
      cameFrom[i] = startID;
      costSoFar.put(i, distBetween);
    }
    
    // add all nodes that can connect to the goal to a list of goalNodes
    dir = nodePos[i].minus(goalPos).normalized();
    distBetween = goalPos.distanceTo(nodePos[i]);
    circleListCheck = rayCircleListIntersect(centers, radii, numObstacles, goalPos, dir, distBetween);
    if (!circleListCheck.hit){
      goalNodes.add(i);
    }
  }
  
  int currentNode = 0;
  
  while(!fringe.isEmpty()) {
    currentNode = fringe.poll().id;
    
    if (currentNode == goalID) {
      break;
    }
    
    if (goalNodes.contains(currentNode)) {
      float priority = costSoFar.get(currentNode) + nodePos[currentNode].distanceTo(goalPos);
      fringe.add(new Node(goalID, priority));
      cameFrom[goalID] = currentNode;
      continue;
    }
    
    for (int i = 0; i < neighbors[currentNode].size(); i++){
      int next = neighbors[currentNode].get(i);
      float newCost = costSoFar.get(currentNode) + distanceBetweenNodes(nodePos, currentNode, next);
      
      if(!costSoFar.containsKey(next) || newCost < costSoFar.get(next)) {
        costSoFar.put(next, newCost);
        float priority = newCost + nodePos[next].distanceTo(goalPos);
        fringe.add(new Node(next, priority));
        cameFrom[next] = currentNode;
      }
    } 
  }
  
  ArrayList<Integer> path = new ArrayList();
  
  if (fringe.isEmpty()) {
    path.add(0,-1);
    return path;
  }
  
  currentNode = cameFrom[currentNode];
  
  while (currentNode != startID) {
    path.add(0, currentNode);
    currentNode = cameFrom[currentNode];
  }
  
  return path;
}

float distanceBetweenNodes(Vec2[] nodePos, int nodeID, int goalID) {
  return nodePos[nodeID].distanceTo(nodePos[goalID]);
}
