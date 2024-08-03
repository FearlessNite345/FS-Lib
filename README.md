# FS-Lib Documentation

![Github All Releases](https://img.shields.io/github/downloads/FearlessNite345/FS-Lib/total.svg)

FS-Lib is a collection of Lua functions designed for FiveM scripts to streamline various common tasks. It is mainly used in FearlessStudios scripts. Below is a detailed guide on how to use each function exposed by FS-Lib.

# Docs 
Feel free to contribute to the docs.

## Exports
[GetKeyStringFromKeyID](#getkeystringfromkeyid)
[GetClosestModelWithinDistance](#getclosestmodelwithindistance)
[GetClosestPedWithinDistance](#getclosestpedwithindistance)
[SetupModel](#setupmodel)
[DrawNotification3D](#drawnotification3d)
[DrawNotification2D](#drawnotification2d)
[DrawText3D](#drawtext3d)
[DrawText2D](#drawtext2d)
[PlaceModel](#placemodel)
[HeadingToCardinal](#headingtocardinal)

---

### GetKeyStringFromKeyID

Retrieves the name of the key corresponding to the provided key ID. This function returns the key name based on the current input device (keyboard or controller).

#### Parameters:
- `keyID`: The ID of the key. For a list of key IDs, refer to the [FiveM documentation](https://docs.fivem.net/docs/game-references/controls/).

#### Returns:
- A tuple where the first element is the key name (`string`) and the second element is the input device type (`number`):
  - `0` for keyboard
  - `1` for controller

#### Example:
```lua
local keyName, deviceType = exports['FS-Lib']:GetKeyStringFromKeyID(38)
print("Key Name: " .. keyName .. "Device Type: " .. deviceType)
```

---

### GetClosestModelWithinDistance

Finds the closest model within a specified distance from the player's current location.

#### Parameters:
- `maxDistance`: The maximum distance within which to search for the model (number).
- `models`: A single model hash or a table of model hashes (number or table).

#### Returns:
- A tuple where the first element is the coordinates of the closest model (vector3), and the second element is the handle of the closest model (number).

#### Example:
```lua
local closestCoords, closestHandle = exports['FS-Lib']:GetClosestModelWithinDistance(50.0, 123456)
print("Closest Model Coords: " .. closestCoords)
print("Closest Model Handle: " .. closestHandle)
```

---

### GetClosestPedWithinDistance

Finds the closest pedestrian (NPC or player) within a specified distance from the player's current location.

#### Parameters:
- `maxDistance`: The maximum distance within which to search for pedestrians (number).
- `searchType`: Type of pedestrian to search for. Use "players" to find players or "npcs" to find NPCs (string).

#### Returns:
- A tuple where the first element is the closest pedestrian (Ped), and the second element is the distance to the closest pedestrian (number).

#### Example:
```lua
local closestPed, distance = exports['FS-Lib']:GetClosestPedWithinDistance(30.0, "players")
print("Closest Pedestrian: " .. closestPed)
print("Distance: " .. distance)
```

---

### SetupModel

Loads and sets up a model for use in the game.

#### Parameters:
- `model`: The model to load (number or string).

#### Example:
```lua
exports['FS-Lib']:SetupModel(123456)
```

---

### DrawNotification3D

Displays a 3D notification at specified coordinates.

#### Parameters:
- `coords`: Coordinates to display the notification (vector3).
- `text`: The text to display (string).
- `seconds`: Duration of the notification in seconds (number).
- `color`: The color of the text in hexadecimal (string).

#### Example:
```lua
exports['FS-Lib']:DrawNotification3D(vector3(100.0, 200.0, 300.0), "Hello World", 5, "#FF0000")
```

---

### DrawNotification2D

Displays a 2D notification on the screen.

#### Parameters:
- `text`: The text to display (string).
- `seconds`: Duration of the notification in seconds (number).
- `color`: The color of the text in hexadecimal (string).

#### Example:
```lua
exports['FS-Lib']:DrawNotification2D("Hello World", 5, "#00FF00")
```

---

### DrawText3D

Draws 3D text at specified world coordinates.

#### Parameters:
- `x`: X coordinate of the text (number).
- `y`: Y coordinate of the text (number).
- `z`: Z coordinate of the text (number).
- `scale`: Scale of the text (number).
- `text`: The text to display (string).

#### Example:
```lua
exports['FS-Lib']:DrawText3D(100.0, 200.0, 300.0, 0.6, "3D Text")
```

---

### DrawText2D

Draws 2D text at specified screen coordinates.

#### Parameters:
- `x`: X coordinate of the text on the screen (number).
- `y`: Y coordinate of the text on the screen (number).
- `text`: The text to display (string).
- `scale`: Scale of the text (number).
- `center`: Whether to center the text (boolean).

#### Example:
```lua
exports['FS-Lib']:DrawText2D(0.5, 0.8, "2D Text", 0.6, true)
```

---

### PlaceModel

Places a model at a specified position with keyboard control.

#### Parameters:
- `model`: The model to place (number or string).
- `position`: The position to place the model (vector3).
- `rotation`: The rotation of the model (vector3).
- `callback`: Function to call after placement (function).

#### Callback Params
- `Success`: will be true if the model was placed otherwise false

###### Only a param if success is TRUE otherwise they will be nil
- `Model`: The model that was actually placed
- `Current Position`: The position the model was placed at
- `Current Rotation`: The roation the model was placed with

#### Example:
```lua
exports['FS-Lib']:PlaceModel(123456, vector3(100.0, 200.0, 300.0), vector3(0.0, 0.0, 90.0), function(Success, Model, CurrentPos, CurrentRot)
    if success then
        print("Model placed successfully.")
        print("Model:" .. Model)
        print("Position:" .. CurrentPos)
        print("Rotation:" .. CurrentRot)
    else
        print("Model placement failed.")
    end
end)
```

---

### HeadingToCardinal

Converts a heading value to a cardinal direction.

#### Parameters:
- `heading`: The heading angle (number).

#### Returns:
- The cardinal direction as a string (string).

#### Example:
```lua
local direction = exports['FS-Lib']:HeadingToCardinal(45)
print("Cardinal Direction: " .. direction)
```

## Contributing

Your contributions are invaluable! If you encounter a bug or have a brilliant enhancement in mind, please don't hesitate to open an issue or submit a pull request. If you would like to write any of the documentation, I would greatly appreciate it!

## License

This project is licensed under the [MIT License](LICENSE), providing you with the freedom to integrate it seamlessly into your own projects.

Happy coding!
