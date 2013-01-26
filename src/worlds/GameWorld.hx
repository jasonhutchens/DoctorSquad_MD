package worlds;

import kranzky.PubNub;
import widgets.Generator;
import widgets.Widget;

import haxe.Json;

import com.haxepunk.HXP;
import com.haxepunk.World;
import com.haxepunk.utils.Input;
import com.haxepunk.graphics.Text;
import com.haxepunk.Entity;

typedef Publishable = {
    @:optional var message : String;
    @:optional var system : String;
    var counter : Int;
  }


class GameWorld extends World
{
  private var _counter:Int;
  private var _pubnub:PubNub;
  private var _messageImage:Text;
  private var _messageEntity:Entity;

  private var _widgets:Array<Widget>;

  public function new()
  {
    super();

    _counter = 1;

    // Create a PubNub instance to handle all messaging. This is for a specific
    // channel, so you might start off with a lobby channel then create one
    // more for the game channel (with a unique name for that game session)
    var pub_key = "pub-c-0834dc19-81c6-4378-9ab7-db3d457d9472";
    var sub_key = "sub-c-132a21ec-66ec-11e2-903d-12313f022c90";
    var channel = "kranzky";
    _pubnub = new PubNub(pub_key, sub_key, channel);

    _messageImage = new Text("Hello");
    var x = HXP.screen.width/2;
    var y = HXP.screen.height/2;
    _messageEntity = new Entity(x, y, _messageImage);

    _widgets = new Array<Widget>();

    addWidget( "generator", false );
  }

  public override function begin()
  {
    add(_messageEntity);
  }

  public function addWidget( type, mine )
  {
    if( type == "generator" )
    {
      var generator = new Generator(_pubnub, mine);
      generator.add( this );
      _widgets.push( generator );
    }
  }

  public override function update()
  {
    if (Input.mousePressed) {
      if (_messageImage.text == "Hello") {
        _messageImage.text = "World";
      } else {
        _messageImage.text = "Hello";
      }
      // Publish an object to subscribers. I suggest you use small hashes like
      // this without nesting or arrays of values if possible; I had lots of
      // pain with Json parsing. Also, each send creates a new thread, so it's
      // possible to exhaust threads and crash if you spam this. The PubNub
      // class should probably instance a pool of threads for sending and reuse
      // them in a round-robin. But I'm too tired for that right now.

      //OLD style - this means every message we publish has to have the same
      //arguments, otherwise compiler error. Publishable allows optional args.
//      var object1 = {
//        message: "hello",
//        counter: _counter,
//        system: Sys.systemName()
//      };
      var object1: Publishable = { message : "test", system : Sys.systemName(), counter : _counter };
      _pubnub.send(object1);
      _counter += 1;

      var object2: Publishable = { system : Sys.systemName(), counter : _counter };
      _pubnub.send(object2);
      _counter += 1;

      var object3: Publishable = { counter : _counter };
      _pubnub.send(object3);
      _counter += 1;
    }
    // Reading requires you give it a callback. This is because it unpicks the
    // array of results returned, so one call to read may hit the callback
    // multiple times, one for each object read. You can do Json parsing in the
    // callback to get the object pack, provided the crappy haxe Json parser
    // can handle it. The parsing should be done within PubNub so you just get
    // an object back, but I didn't know how to specify the message type to the
    // anonymous function.
    _pubnub.read(function(message) {
      trace("READ: " + message);
      var object = Json.parse(message);
    });
    super.update();
    // Also update widgets (they're not entities)
    for (widget in _widgets) {
      widget.update();
    }
  }
}
