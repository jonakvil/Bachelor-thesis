


public class VirtualPerson{
  private int id;
  public float x, y;
  public boolean inUse;
  
  
  public VirtualPerson(int id, float coordX, float coordY){
    this.id = id;
    this.x = coordX;
    this.y = coordY;
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
