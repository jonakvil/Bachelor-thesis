//circular buffer to count averaged fps
import java.util.*;

public class FPS {
  private int capacity;
  private ArrayList<Integer> data;
  private int position;

  public FPS(int capacity) {
    this.capacity = capacity;
    this.data = new ArrayList<Integer>();
    this.position = 0;
  }
  public void insert(int fps) {
    if (position != capacity-1) {
      data.add(fps);
      position++;
    } else {
      position = 0;
      data.set(position, fps);
    }
  }
  public int getAvg() {
    int avg = 0;
    int i = 0;

    for (int fps : data) {
      avg += fps;
      i++;
    }
    avg /= i;
    return avg;
  }
}
