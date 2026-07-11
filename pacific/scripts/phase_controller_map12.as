// the blank file is intended:
// - vanilla's map_rotator_invasion.as which we use too includes phase_controller_map12.as 
//   as a mistake, and without making the file blank, it would introduce class named Phase,
//   but we also have our own class named Phase in phase_controller_island1.as
// - this file can be removed once vanilla removes inclusion of phase_controller_map12.as 
//   in map_rotator_invasion.as