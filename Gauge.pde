/**
*Library for creating customzable gauges with max and min values.
*
*This library creates a PGraphics object that can be drawn using 'image()'.
*
*Gauge.pde currently contains some hard-coded placement values and
*may not look right out of the box with alternate fonts or sizing.
*/


class Gauge{

    PVector _pos;
    float _rangeMin;
    float _rangeMax;
    float _range;
    float _size;
    float _curVal;
    float _minRadians;
    float _maxRadians;
    float _radianRange;
    float _displayVal;
    boolean _active = true;
    float _shadowOffset;
    float _accelerationVal;
    PGraphics _buffer;
    color _gaugeColor;
    color _gaugeShadowColor;
    color _textColor;
    PFont klavika; //The AMD brand font. Can be replaced with any font.
    String _description;

    Gauge(PVector p, float rangeMin, float rangeMax){
        _size = 200;
        _description = "undefined";
        _buffer = createGraphics(int(_size * 1.5), int(_size * 1.5)); //Image buffer 
         klavika = createFont("Klavika-Medium.otf", 60); //Font file must exist in the "data" folder for this sketch
        _pos = p;
        _rangeMin = rangeMin;
        _rangeMax = rangeMax;
        _range = rangeMax - rangeMin;
        _curVal = 0;
        _displayVal = _curVal; //displayVal will be used to smooth the transition animation between values
        _minRadians = -3.92699; //starts angle at southwest quadrant
        _maxRadians = 0.785398; // ends angle at southeast quadrant
        _radianRange = _maxRadians - _minRadians;
        _gaugeColor = #FF0000;
        _gaugeShadowColor = #94A69B;
        _textColor = #BAC8D6;
        _shadowOffset = 5;
        _accelerationVal = 10;
    }

    void update(float i){
        _buffer.noFill();
        _buffer.imageMode(CORNER);
        _curVal = i;
        updateDisplay();
        float r = valToRadians(_displayVal);
        _buffer.stroke(_gaugeShadowColor);
        _buffer.ellipseMode(CENTER);
        
        _buffer.beginDraw();
 
        _buffer.strokeWeight(20.0);
        _buffer.clear();
        
        _buffer.arc(_pos.x, _pos.y, _size, _size, _minRadians, _maxRadians, OPEN);
        _buffer.stroke(_gaugeColor);
        
        _buffer.arc(_pos.x, _pos.y, _size, _size, _minRadians, r, OPEN);
          drawText();
        _buffer.endDraw();

    }

    void changePos(int x, int y){
      _pos = new PVector(x,y);
    }
    
    void setDescription(String d){
      _description = d;
    }

    void changeSize(float s){
      _size = s;
      _buffer = createGraphics(int(_size), int(_size));
    }

    float getValRatio(float val){
      val = clipValue(val);
      val = val - _rangeMin;
      val = val / _range;
      return val;
    }

    float valToRadians(float v){
      float val = getValRatio(v);
      val = (val * _radianRange) + _minRadians;
      return val;
    }

    float clipValue(float v){
      if (v < _rangeMin){
        v = _rangeMin;
      }
      else if (v > _rangeMax){
        v = _rangeMax;
      }
      return v;
    }

    void updateDisplay(){ // Use acceleration to make display values slowly move to actual value
      float d = _curVal - _displayVal;
      d /= _accelerationVal;
      _displayVal += d;

    }

    void drawText(){
      String t = str(floor(_displayVal));
      _buffer.beginDraw();
      _buffer.textFont(klavika);
      _buffer.textAlign(CENTER);
      _buffer.textSize(90);
      _buffer.fill(_textColor);
      _buffer.text(t, _buffer.width / 2, _buffer.height / 2);
      _buffer.textSize(40);
      _buffer.text(_description, _buffer.width / 2, _buffer.height - 45);
      _buffer.endDraw();
    }
    
    PGraphics display(){
      return _buffer;
    }

}
