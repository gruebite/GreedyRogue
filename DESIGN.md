
# GreedyRogue

GreedyRogue is a 2022 7DRL Game Jam entry.  This is the design document, and defines some of the minimum project requirements.

## Overview

### Story

You play as a Rogue looting treasure from a Dragon's Lair under a volcano.  You've picked a time when the Dragon is out terrorizing the local village.  Unfortunately you didn't anticipate there being Dragonlings.  But you're greedy and anxious, and continue anyway.

### Mechanics

GreedyRogue is similar to a traditional Roguelike: permadeath, procedural generation, turn-based.  The core gameplay revolves around resource management and movement constraints.

You start out in a chamber.    You can only see things directly nearby, but can make out vague details of things further out.  Some treasure is special, and grants you certain advantages, like a torch to increase sight range, or jumping boots allowing you to stay greedy by jumping over gaps in treasure.  Only after filling your bag, will you consider making an escape.

Dragonlings wake up the more treasure you grab.  They move randomly, and breathe fire which melts treasure.  You can see them when awake because they emit a small amount of light.

#### The Rogue

The Rogue has two main concerns:

- Health.  Can be used to overcome certain challenges.  Difficult to recover.  If health reaches 0, game over.
- Anxiety.  Always increases, especially with certain actions.  Grabbing treasure decreases anxiety.  If anxiety reaches max, game over.  (Side-effects from high anxiety?)

#### Chamber (Dragon's Lair)

This is where you spawn.  It is dark, and contains treasures, environmental obstacles, and creatures.

You can only exit after acquiring enough treasure.

#### Darkness & Light

Light has two ranges: lit and dim.  Lit objects are completely revealed, dim objects are only faintly recognized.

Various things emit light like lava, dragon's fire, and torches.  You start out with a candle which has a small range.

#### Treasure

Treasure is spread out randomly in piles of different sizes.  Treasure can be gold, or chests.  Chests can contain valuable items which can provide passive bonuses or be activated:

- Extra gold
- Health Potion
- Jumping Boots
- Torch

#### Obstacles

- Chasm.  Impassible.
- Pitfalls.  Can only see up close.  Cracks twice, third breaks causing a chasm.
- Lava.  Provides light.  Take damage to walk over.
- Stalagmites.  Can be pushed over to attack, or create walkways over lava.
- Weak walls.  Can be broken down.
- Walls.  Impassible.

#### Creatures

- Dragonlings.  Wanders randomly, and breaths fire randomly, which melts treasure.

## Technical

### Programming

- Dungeon generation will be a random walk.
- Field of view will be a recursive shadow cast.
- AI will be state machines.

### Graphics

#### Environment

Lit & dim variants.
- Cavern floor.
- Cavern wall.
- Weak cavern wall.
- Stalagmite.
- Chasm.

Lit only.
- Cracking floor.  2 Stages.

#### Entities

Lit only.  Animated.
- Lava.
- Fire.
- Melted treasure.
- Gold.
- Chest.

Animated.  Dim only.
- Glimmering treasure.

Lit & dim variants.  Animated. (idle only animation?)
- Rogue.
- Dragonling.  Sleeping, wandering, preparing, breathing

#### Effects

- Rock explosion.  For stalagmites.
- Fire burning.  For lava walking.

### Sound

- Title.  Fanfare. (final fantasy fanfare?)
- Chamber.  Anxious. (pokemon cave music?)
- Ambience.  Lava bubbles, echoes, rocks falling.

- Gold pickup.  Ding.
- Fire damage.  Tsst.
- Claw attack.  Rip.
- Fire breath.  Explosion.
- Cracking.

## Future

### Creatures

- Mimic
- Earth Elemental
