/*:

# Creating a Generic Protocol with an Associated Type

I want my @2x iPhone assets to be half the size of their @2x iPad counterparts. It's a massive waste of resources to have the iPhones load assets designed to look good on the larger iPad screens onto their much smaller screens.

However, because iOS treats the @2x iPad and iPhone assets equally, I need to change the data to make sure that the iPhone gets information that reflects that these assets are half the size of their iPad equivalents (even if they're both seen as iOS as @2x assets).

If i have a 200 x 200 point sprite at position 100, 100 on an iPad, then a 100 x 100 point sprite would need to be at position 50, 50 in order to look like it's in the same place on an iPhone.

![Image illustrating the above sentence](Halvable.png)

## The Halving protocol

This protocol defines an `associatedType` called `HalvingType`. When other types conform to this protocol, they must specify a `typeAlias` that tells the protocol what type they want `HalvingType` to be seen as in their particular implementation.

They must also implement a specific initialisation method. This method takes the associated type, `HalvingType`, which the implementation should use to initialise all of their properties. During this process, they should half any relevant types (floats, integers, sizes, points, etc.) before assigning them to their properties.
*/

import SpriteKit
import UIKit
import PlaygroundSupport

public protocol Halving {
	associatedtype HalvingType
	init(byHalving item: HalvingType)
}

/*:

### Adding Characters

As I'm developing an adventure game, I'm going to need some characters. I'll define a `Character` struct. All of my character data will be stored in an external JSON file. I'll make this struct conform to `Codable` so that I can easily read or write to the JSON file.
*/

struct Character : Codable {
	let name : String
	let position : CGPoint
	let spriteName : String
}

/*:
In the extension, I'll add conformance to the `Halving` protocol. I'll declare the `HalvingType` to be of the same type `Character`. I'll then implement the initialisation method, making sure to half the character's position.

The benefits of this approach become apparent. If I add an additional property to the `Character` struct at a later date, the compiler will throw an error if I then forget to add this property to the `Halving` protocol implementation.

If you are viewing this Playground in Xcode or on the iPad, try adding `let size : CGSize` to the `Character` struct above.
*/

extension Character : Halving {
	typealias HalvingType = Character
	init(byHalving item: HalvingType) {
		self.name = item.name
		self.position = CGPoint(x: item.position.x / 2, y: item.position.y / 2)
		self.spriteName = item.spriteName
	}
}

/*:
Now that I can create characters, I'll need a room for them to exist in.
*/
struct Room : Codable {
	let name : String
	var characters : [Character]
	let spriteName : String
}

/*:
The `Room` struct doesn't have any properties that need halved itself. However, it does hold an array of `Character` items that *do* need to be halved. By declaring conformance to the protocol, I can have it loop through all of the `Character` instances and create new half-size versions of them.

As the `Room` struct is at the root of my JSON, doing this will ensure that every type that conforms to the `Halving` protocol will get converted. As it is an `init` method, it also means that I will be reminded to do this for any new types I add later.

To make sure that every `Character` item is halved, I'll iterate through the `characters` property and map each item to a new `Character` instance using the `init(byHalving:)` method. By passing it the existing `Character` struct instance (represented by the anonymous argument `$0`), it will return a new `Character` instance with the `position` property halved.
*/
extension Room: Halving {
	typealias HalvingType = Room
	init(byHalving item: HalvingType) {
		self.name = item.name
		self.characters = item.characters.map({Character(byHalving: $0)})
		self.spriteName = item.spriteName
	}
}

/*:
One of the major systems in an adventure game is the player's inventory. Inventories consist of an array of items that players pick up over the course of the game. They can also be carried from room to room, so it makes sense to keep their data in a separate JSON file.

First, I'll declare the `Item` struct that will represent the individual items that a player has picked up.
*/
struct Item : Codable {
	let name : String
	let size : CGSize
	let spriteName : String
}

/*:
The `size` property on the `Item` struct will need to be halved to make it suitable for running on phones. I'll add conformance to the `Halving` protocol.
*/
extension Item : Halving {
	typealias HalvingType = Item
	init(byHalving item: HalvingType) {
		self.name = item.name
		self.size = CGSize(width: item.size.width / 2, height: item.size.height / 2)
		self.spriteName = item.spriteName
	}
}

/*:
Next, I'll create the inventory itself. It simply stores an array of inventory items.
*/
struct Inventory : Codable {
	var items : [Item]
}

/*:
Like the `Room`, however, it will be at the root of the JSON file. Adding the `Halving` conformance ensures that every item will be halved when exporting for iPhones.
*/
extension Inventory : Halving {
	typealias HalvingType = Inventory
	init(byHalving item: Inventory) {
		self.items = item.items.map({ Item(byHalving: $0) })
	}
}

/*:

## Seeing It In Action, A Tale in One Act

There's a bar I frequent. It's a bit run down now, but I know the barman well. His name's Barman.
*/

let jsonString = """
{
  "spriteName" : "bar.png",
  "characters" : [
    {
      "name" : "Barman",
      "position" : [
        100,
        100
      ],
      "spriteName" : "barman.png"
    }
  ],
  "name" : "Bar"
}
""".data(using: .utf8)!
/*:
It's already getting dark as I pull up outside and open the familiar faded brown door.
*/
let jsonDecoder = JSONDecoder()
var 🏚 = try jsonDecoder.decode(Room.self, from: jsonString)
/*:
"Hey," says Barman as I enter. My drink is already poured and he places it down in front of me.
*/
let 🍺 = Item(name: "Pint", size: CGSize(width: 30, height: 50), spriteName:"pint.png")
var 📦 = Inventory(items: [🍺])
/*:
"Here's a menu," He says as he hands me a thick card.

It has swirls on it. I glance over it before placing it down on the counter.

"I'm not hungry," I reply. "Anyway, what's with the fancy paper and the ivy in the corner?"

"Just hired a new chef, didn't I?," he replies, beaming. "His name's Chef."
*/
let 👨🏻‍🍳 = Character(name: "Chef", position: CGPoint(x: 500, y: 300), spriteName: "chef.png")
🏚.characters.append(👨🏻‍🍳)
/*:
"I'm making you a burger!" Shouts Chef from the kitchen.

There's a loud sizzling and a glorious smell fills the air. Barman nods encouragingly at me.

"Yeah, OK. Maybe a little bit hungry," I say, smiling back.

The door opens and we both glance over. A striking woman carrying a small briefcase walks in.
*/
let 👩‍🦳 = Character(name: "Striking Woman", position: CGPoint(x: 0, y: 50), spriteName: "striking-woman.png")
🏚.characters.append(👩‍🦳)
/*:
She sits down next to me and places the briefcase on the counter. Ignoring Barman's welcoming smile, she turns to face me.

"I hear you know how to get things done," she says.

"No hello?" I reply. "No how's it going? No 'Martini, please'?"

She clicks open the briefcase, puts something on the bar and slides it slowly over to me.

I look down.
*/
let 💵 = Item(name: "Money", size: CGSize(width: 20, height: 40), spriteName: "money.png")
📦.items.append(💵)
/*:
I smell danger (although that could just be the onions) but I haven't worked in six months. I don't have a choice.

"When do I start?" I ask.

"Right now," she says.

She gets up and opens the door, then looks back at me.

"Well?" She says.

"Raincheck on the burger?" I say to Barman.

He nods.

I follow her out.

## Saving for Smaller Devices

Now that I have the game running, I want to be able to pick it up later on my iPhone. As the iPhone is running assets that are half the size of the iPad, I'll need to make sure that everything is halved first.
*/
let half🏚 = Room(byHalving: 🏚)
let half📦 = Inventory(byHalving: 📦)

let jsonEncoder = JSONEncoder()
jsonEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]
let 🏚Data = try jsonEncoder.encode(half🏚)
let 📦Data = try jsonEncoder.encode(half📦)

/*:
Let's see what we get:
*/
if let 🏚String = String(data: 🏚Data, encoding: .utf8) {
	print(🏚String)
}
if let 📦String = String(data: 📦Data, encoding: .utf8) {
	print(📦String)
}

/*:

(For those not running the Playground)

🏚Data:

	{
		"characters" : [{
			"name" : "Barman",
			"position" : [ 50, 50 ],
			"spriteName" : "barman.png"
		},{
			"name" : "Chef",
			"position" : [ 250, 150 ],
			"spriteName" : "chef.png"
		},{
			"name" : "Striking Woman",
			"position" : [ 0, 25 ],
			"spriteName" : "striking-woman.png"
		}],
		"name" : "Bar",
		"spriteName" : "bar.png"
	}

📦Data:

	{
		"items" : [{
			"name" : "Pint",
			"size" : [ 15, 25 ],
			"spriteName" : "pint.png"
		},{
			"name" : "Money",
			"size" : [ 10, 20 ],
			"spriteName" : "money.png"
		}]
	}

Compare this with the original declarations, and we can see that the sizes and positions have all been halved.

## Conclusion

Generic protocols with associated types is a powerful Swift feature.

I can now develop games using full size iPad assets (at the equivalent of @4x on the iPhone) and use point values and asset catelogs. I can then resize these images by 3/4 and 1/2 to get their @3x and @2x (which is also iPad @1x) equivalents for the iPhone.

The game can be laid out in JSON objects using the iPad's dimensions. When they are then deserialised on an iPhone, I can pass the created objects through this protocol's initialisation and they will be converted to the iPhone's dimensions, ensuring the 1/2 (@2x) and 3/4 (@3x) sized assets will be properly placed and sized on an iPhone.
*/
