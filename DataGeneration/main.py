import src.f1_data as f1

def main():
    f1.enable_cache()
    session = f1.load_race_session(2025, 12)
    race_telemetry = f1.get_race_telemetry(session)
    result = f1.generate_track_layout(session)

if __name__ == "__main__":
    main()
