# do 19-EDO calculations
base_frequency = 130.8128
notes_per_octave = 19
ratio = math.pow(2, (1 / notes_per_octave))
frequencies = [base_frequency]
rounded_frequencies = [round(base_frequency)]

for index in range(1, 2 * notes_per_octave + 1):
    frequencies.append(ratio * frequencies[index - 1])
    rounded_frequencies.append(round(frequencies[index]))

print(frequencies)
print(rounded_frequencies)
