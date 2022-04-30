


public class VirtualPerson{
  private int id;
  public float x, y;
  public boolean inUse;
  public int timeStamp;
  
  public VirtualPerson(int id, float coordX, float coordY, int timeStamp){
    this.id = id;
    this.x = coordX;
    this.y = coordY;
    this.timeStamp = timeStamp;
    this.inUse = false;
  }
  
  public void updateCoords(int x, int y){
   this.x = x;
   this.y = y;    
  }
  
  public int getId(){
   return id; 
  }
  
  public void setId(int _id){
    this.id = _id; 
  }
}

public class DyingPerson{
  private int id;
  public int timeStamp;
  
  public DyingPerson(int id, int timeStamp){
    this.id = id;
    this.timeStamp = timeStamp;
  }
  
  
  public int getId(){
   return id; 
  }
  
  public void setId(int _id){
    this.id = _id; 
  }
  
  
}
