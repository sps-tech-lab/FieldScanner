class Rectangle{
  int x;
  int y;
  int w;
  int h;
  color fill_color;
  color border_color;
  Rectangle(int _x,int _y,int _w,int _h,color _fill, color _border){
    x = _x;
    y = _y;
    w = _w;
    h = _h;
    fill_color = _fill;
    border_color = _border;
  }
  void draw(){
    fill(fill_color);
    stroke(border_color);
    rect(x,y,w,h);
  }
}


/**
  **************************************************************************************************
  * @brief      Look for longest string in String array and return it's width
  **************************************************************************************************
**/
float getLongestStringWidth(String[] array){
  String longestString = "";
  for (int i = 0; i < array.length; i++){
    if (array[i].length() > longestString.length()){
      longestString = array[i];
    }
  }
  return textWidth(longestString);
}
