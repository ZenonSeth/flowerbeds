# Flowerbeds

## Description

Flowerbeds are blocks that allow easier growing of flowers. Once you place a flower on top of a flowerbed, it will grow in nearby empty flowerbeds.

This growing is not limited by the usual restriction of flora density, so a single flower planted in a large flowerbed field will eventually fill the entire field with the flower.

In order to grow new flowers, flowerbeds must be on the same vertical height, and adjacent - even diagonally - to each other.

Flowerbeds are crafted from 1 coal, 1 dirt and 1 wood placed vertically.
Different woods yields different looking flowerbeds, but they all share the same functionality and can work with each other.

Flower beds have a random time between checks, and random probability of success, to see if flowers grow in empty flowerbeds. The times and probability can be controlled with the [Settings] listed below.

## Flower Compatibility

Flowerbeds grow flowers based on groups, so any mod that adds new flowers and correctly tags them with the "flower" group should be compatible with Flowerbeds.

### Game Compatibility

Depending on the game you are playing the following mods should be present:

* Minetest Game, and all derivatives: `default`. Specifically needs wood textures to be present and sounds functions to be present.
* Mineclonia: `mcl_core`, `mcl_trees`, `mcl_sounds`
* Voxelibre: `mcl_core`, `mcl_bamboo`, `mcl_mangrove`, `mcl_cherry_blossom`, `mcl_sounds`

## Settings

### flowerbeds_min_spread_time

This setting sets the minimum time between checks.

Defaults to 25 seconds.

### flowerbeds_max_spread_time

This setting sets the maximum time between checks.

Defaults to 45 seconds.

### flowerbeds_min_removed_time

Once a flower bed has a flower it will regularly check to see if the flower has
been removed and if it should check to see if a flower spreads to it. This is
the minimum time for those checks.

Defaults to 80 seconds.

### flowerbeds_max_removed_time

This is the maximum time for checks to see if a flower has been removed.

Defaults to 120 seconds.

### flowerbeds_chance

This is the chance out of 100 for an adjacent flower to spread to this flower
bed.

Defaults to 25.

## Credits
- Main development: [Zenon Seth](https://github.com/ZenonSeth)
- Additional work: [Codiac](https://codeberg.org/Codiac)
