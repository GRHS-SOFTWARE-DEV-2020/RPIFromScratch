
// Values for defining the current build target's features

.set __system__, 32     // bus width (32, 64)
.set __device__, 33     // rpi device internal alias, first place is the tens, second follows rule = (a = 0; a+ = 1, b = 2, b+ = 3) this is the typical. the Zero series starts at 1


.set __build_all__, 1   // master build, (if value != 1 then value = 0)

.if (__build_all__ == 1)
.set __build_driver__, 








.else

.endif
