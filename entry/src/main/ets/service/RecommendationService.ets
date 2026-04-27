export interface RecommendationService {
  getRecommendations(): Promise<Recommendations>
}

export interface Recommendations {
  article: {
    id: string,
    title: string,
    updateTime: number
  },
  herb: {
    id: string,
    name: string,
    updateTime: number
  },
  updateTime: number
}
