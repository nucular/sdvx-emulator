# KSH Format description

*Note: This is not supposed to be a full specification. It was written using
reverse-engineering and is probably incomplete.*

A K-Shoot MANIA chart consists of the track as OGG Vorbis audio and multiple KSH
files with their accompanying effect tracks (which replace the audio when FX
or laser objects are being played), one for each difficulty level.

KSH is a simple text (UTF-8 CRLF) format made of multiple lines that are either
assignments, events or measure markers.

### Assignments (`identifier=value`)

Assignments are used to set metadata and parameters like the current BPM. The
area before the first measure marker is considered the metadata section, after
that only identifiers marked as *variable* should be changed.

- `title=text`: the song title (*required*)
- `artist=text`: the song artist (*required*)
- `effect=text`: who created the map and effects (*required*)
- `jacket=path`: the song cover image, relative to the KSH file (*required*)
- `illustrator=text`: who illustrated the cover (*required*)
- `difficulty=light/challenge/extended/infinite`: the difficulty (*required*)
- `level=number`: the difficulty level, from 1 to 20 (*required*)
- `t=number`: the song BPM (*required, variable*)
  - If a BPM change is used in the map, the BPM assignment in the metadata
    has to be formatted like `t=minimum-maximum` instead and the starting BPM
    assignment has to be moved behind the first measure marker!
- `m=path;path`: the path to the track without effects followed by the path to
  the track with effects (*required*)
- `mvol=number`: the volume the track is played with, from 1 to 100 (**required?**, **variable?**)
- `o=number`: **unknown**
- `bg=name`: the name of the background to be used (**required?**, **variable?**)
- `layer=name`: the name of the side animation to be used (**required?**, **variable?**)
- **...**

### Events (`beat|fx|lr`[`@lanefx`])

### Measure markers (`--`)

Measures can hold one or more events. The number of events between two measure
markers decides the granularity (i.e. speed) of the measure and can be either
1, 2, 4, 8, 16, 32, 48 or 64. Assignments don't count as events and are applied
right before the next event instead.
