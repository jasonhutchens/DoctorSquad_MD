package widgets;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.utils.Input;
import com.haxepunk.World;
import com.haxepunk.HXP;

class Generator extends Widget
{

  private var _darkness:Entity;
  private var _switch:Switch;

  public function new( pubnub, canInteract )
  {
    super( pubnub, canInteract );

    trace("new generator");

    _pubnub = pubnub;

    var _darknessImage = Image.createRect(HXP.screen.width, HXP.screen.height, 0x000000);
    var x = 0.0;
    var y = 0.0;
    _darkness = new Entity(x, y, _darknessImage);

    x = HXP.screen.width/2;
    y = HXP.screen.height/2;
    _switch = new Switch(x, y, switchChanged, _canInteract);

    switchChanged();
  }

  public override function update()
  {
    // widget state updated here (eg fade out an element)
  }

  public override function add( world:World ):Void
  {
    world.add(_switch);
    world.add(_darkness);
  }

  public override function remove( world:World ):Void
  {
    world.remove(_switch);
    world.remove(_darkness);
  }

  private function switchChanged():Void
  {
    trace("switch changed");
    if(_switch.on) 
    {
      cast(_darkness.graphic, Image).alpha = 0.1;
    } else {
      cast(_darkness.graphic, Image).alpha = 0.8;
    }
  }
  
}