# FS-Lib

![Github All Releases](https://img.shields.io/github/downloads/FearlessNite345/FS-lib/total.svg?style=for-the-badge)
![GitHub Downloads (all assets, latest release)](https://img.shields.io/github/downloads/fearlessnite345/fs-lib/latest/total?style=for-the-badge)

FS-Lib is a collection of Lua functions designed for FiveM scripts to streamline various common tasks. It is mainly used in FearlessStudios scripts. Below is a detailed guide on how to use each function exposed by FS-Lib.

# Documentation

Feel free to contribute to the docs.

## Table of Contents

- [GetKeyStringFromKeyID](#getkeystringfromkeyid)
- [GetClosestObjectWithinDist](#getclosestobjectwithindist)
- [GetClosestPedWithinDist](#getclosestpedwithindist)
- [GetObjectsWithinDist](#getobjectswithindist)
- [GetPedsWithinDist](#getpedswithindist)
- [SetupModel](#setupmodel)
- [DrawText3D](#drawtext3d)
- [DrawText2D](#drawtext2d)
- [PlaceModel](#placemodel)
- [HeadingToCardinal](#headingtocardinal)
- [VersionCheck](#versioncheck)

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

### GetClosestObjectWithinDist

Finds the closest object within a specified distance from the player's current location.

#### Parameters:

- `maxDistance`: The maximum distance within which to search for the model (number).

#### Returns:

- `closestObj`: The object it found
- `closestDist`: The distance to that object
- `closestCoords`: The coords of the object

#### Example:

```lua
local closestPed, closestDist, closestCoords = exports['FS-Lib']:GetClosestObjectWithinDist(50.0)
```

---

### GetClosestPedWithinDist

Finds the closest pedestrian (NPC or player) within a specified distance from the player's current location.

#### Parameters:

- `maxDistance`: The maximum distance within which to search for pedestrians (number).
- `searchType`: Type of pedestrian to search for. Use "players" to find players or "npcs" to find NPCs or "both" to find both (string).

#### Returns:

- `closestPed`: The ped it found
- `closestDist`: The distance to that ped
- `closestCoords`: The coords of the ped

#### Example:

```lua
local closestPed, closestDist, closestCoords = exports['FS-Lib']:GetClosestPedWithinDist(30.0, "players")
```

### GetObjectsWithinDist

Finds the objects within a specified distance from the player's current location.

#### Parameters:

- `maxDistance`: The maximum distance within which to search for the model (number).

#### Returns:

- A table of all objects

#### Example:

```lua
local objects = exports['FS-Lib']:GetObjectsWithinDist(30.0)

for _, data in ipairs(objects) do
    print(data.object)
    print(data.objCoords)
    print(data.dist)
end
```

---

### GetPedsWithinDist

Finds the peds (NPC or player or both) within a specified distance from the player's current location.

#### Parameters:

- `maxDistance`: The maximum distance within which to search for pedestrians (number).
- `searchType`: Type of pedestrian to search for. Use "players" to find players or "npcs" to find NPCs or "both" to find both (string).

#### Returns:

- A table of all peds

#### Example:

```lua
local peds = exports['FS-Lib']:GetPedsWithinDist(30.0, "players")

for _, data in ipairs(peds) do
    print(data.ped)
    print(data.dist)
    print(data.pedCoords)
end
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

### PlaceObject

Places a object at a specified position with keyboard control.

#### Parameters:

- `model`: The model to place (number or string).
- `position`: The position to place the model (vector3).
- `rotation`: The rotation of the model (vector3).
- `callback`: Function to call after placement (function).

#### Callback Params

- `Success`: will be true if the model was placed otherwise false

###### Only a param if success is TRUE otherwise they will be nil

- `Object`: The model that was actually placed
- `Current Position`: The position the model was placed at
- `Current Rotation`: The roation the model was placed with

#### Example:

```lua
exports['FS-Lib']:PlaceModel(123456, vector3(100.0, 200.0, 300.0), vector3(0.0, 0.0, 90.0), function(Success, Object, CurrentPos, CurrentRot)
    if success then
        print("Object placed successfully.")
        print("Object:" .. Object)
        print("Position:" .. CurrentPos)
        print("Rotation:" .. CurrentRot)
    else
        print("Object placement failed.")
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

---

### VersionCheck

Checks latest github release version vs the current resource version

#### Parameters:

- `resourceName`: The name of the resource for printing purposes
- `githubRepo`: This is the actual repo to check must be in `'username/repo'` format

#### Example:

```lua
exports['FS-Lib']:VersionCheck('FS-Lib', 'fearlessnite345/fs-lib')
```

## Contributing

Your contributions are invaluable! If you encounter a bug or have a brilliant enhancement in mind, please don't hesitate to open an issue or submit a pull request. If you would like to write any of the documentation, I would greatly appreciate it!

## License

This project is licensed under the [MIT License](LICENSE), providing you with the freedom to integrate it seamlessly into your own projects.

Happy coding!
