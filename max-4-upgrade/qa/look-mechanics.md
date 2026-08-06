# Max look mechanics

Max is a closed-helmet racing-driver pet. The feet, lower legs, and lower torso stay anchored to the shared baseline while the helmet and upper torso provide the direction cue. The rigid helmet shell yaws around the neck and pitches slightly for up/down targets; the red visor band, white helmet panels, and small yellow side details shift with the shell rather than sliding independently. The navy suit remains stable, with a restrained upper-torso follow-through so Max does not look like a rotated whole sprite.

Cardinal pose families:

- `000` up: helmet pitches upward, exposing more of the lower visor/neck relationship and reducing the visible front shell; feet and lower torso remain fixed.
- `090` screen-right: helmet yaws toward screen-right, with the right-facing helmet side becoming more visible and the opposite side partially occluded.
- `180` down: helmet pitches downward, showing more of the crown and top red-white markings while the visor band compresses toward the torso.
- `270` screen-left: helmet yaws toward screen-left, mirroring the side-visibility logic of `090` in screen coordinates without flipping the sprite as a whole.

The 22.5-degree intermediates interpolate helmet yaw/pitch, visor foreshortening, side-panel visibility, and small upper-torso follow-through evenly around the clockwise loop. The lower-body anchor, silhouette scale, palette, visor construction, suit markings, and helmet props remain stable. No whole-sprite rotation, skew, detached effects, new eyes, labels, or guide marks are allowed.
