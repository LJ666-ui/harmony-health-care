import { LocationService, UserLocation } from './LocationService'

export class LocationServiceMock implements LocationService {
  async getUserLocation(): Promise<UserLocation> {
    let userLocation: UserLocation = {
      latitude: 39.9042,
      longitude: 116.4074,
      accuracy: 10
    }
    return userLocation
  }
}
