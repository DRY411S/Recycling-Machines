# Recycling Machines
A factorio mod that adds Recycling Machines to the game.

If you can assemble something in a Factorio 'vanilla' assembling machine, then you can 'disassemble' it (or recycle as I
prefer to call it) in one of these Recycling Machines, back to the original ingredients.

# How it works

When you start a new game

The mod looks for every recipe (including any recipes in installed mods). If the recipe can be made in an
assembling machine, this mod creates a 'reverse recipe' that can be made in recycling machines.

The research tree is altered so that every time a Level X assembling machine is reaserched, a Level X recycling machine
will be researched at the same time.

As you play the game

Every time research is completed for something that can be made in an assembling machine, the game enables its recipe as normal.
At the same time, the mod enables the 'reverse recipe'. So as the crafting recipes grow in game, the recycling machine recipes grow too.

The interface for the recycling machine is exactly the same as an assembling machine. You decide what the input will be,
and my mod tells you what the outputs are going to be.

# Why I made this mod

One time whilst playing the game, I was having a real problem with a copper shortage, and needed circuits badly. All the copper ore
fields that I could find were close to spawners, and I didn't have much weaponry (and I'm useless at fighting anyway).

On doing an review of my inventory, because of the placement of one bad active provider chest, I realised that I had over 10,000
Green copper wires, and the same amount of Red copper wires. I figured I could get copper cable (and the circuits) back
if I could recycle those wires.

I looked at the other recycling mods out there, and they were all based on furnaces. They would work for me, but I didn't think
they were 'realistic' for 3 reasons.

First, a furnace based recycler accepts 'anything'. I wanted recycling machines that were specialised,
where you had to decide what you wanted to recycle. I thought that was more realistic than furnaces, and my idea was validated when I
saw this YouTube video https://www.youtube.com/watch?v=N5GBGbcDY6c. No heat required!

Second, I didn't like how a lot of the furnace based recycling mods allowed 'unsmelting', turning iron-plate back into iron-ore and coal
for example. I figured that if the recycling machine was recipe based, and would allow only certain recycling recipes, then I
could stop that from happening.

Third, because the other mods are furnace-based, the furnace in Factorio will not input or output fluids which is a limitation.
Why shouldn't I be able to recycle an electric-engine and get the lubricant out of it for example? A quick test showed me that I could
turn a fluid input in an assembling machine into an output on my recycling machine.

So then I coded it all, and here it is.
