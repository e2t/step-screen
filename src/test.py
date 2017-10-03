from screen import calc_step_screen


def test_screen(oriental_ext_width: float, ejection_height: float,
                moving_plate_thickness: float, fixed_plate_thickness: float,
                gap: float, depth_channel: float) -> None:
    screen = calc_step_screen(oriental_ext_width, ejection_height,
                              moving_plate_thickness, fixed_plate_thickness,
                              gap, depth_channel)
    print("external_width = {0}, ejection_height = {1}, mass = {2:.0f}".format(
        screen.external_width, screen.ejection_height, screen.weight))


def test() -> None:
    test_screen(1850, 3110, 2, 3, 6, 2060)  # 1821, mass=2803
    test_screen(963, 2460, 3, 2, 6, 1400)  # 0915, mass=1449 kg
    test_screen(1050, 2460, 3, 2, 6, 1400)  # 1015, mass=1545 kg


if __name__ == "__main__":
    test()
