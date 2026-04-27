import { RecommendationService, Recommendations } from './RecommendationService'

export class RecommendationServiceMock implements RecommendationService {
  async getRecommendations(): Promise<Recommendations> {
    let recommendations: Recommendations = {
      article: {
        id: 'article_1',
        title: '高血压预防指南',
        updateTime: Date.now()
      },
      herb: {
        id: 'herb_1',
        name: '枸杞',
        updateTime: Date.now()
      },
      updateTime: Date.now()
    }
    return recommendations
  }
}
