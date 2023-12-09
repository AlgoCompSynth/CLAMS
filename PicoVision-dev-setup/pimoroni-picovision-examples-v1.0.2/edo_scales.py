while True:
    for note in rounded_frequencies:
        noise.frequency(note)
        noise.trigger_attack()
        time.sleep(1.0)
