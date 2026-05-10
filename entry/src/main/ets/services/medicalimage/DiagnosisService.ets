import http from '@ohos.net.http';
import { UploadResponse, AnalyzeResponse, ImageType, DiagnosisResult, Lesion } from '../types/medicalimage/MedicalImageTypes';
import { API_ENDPOINTS } from '../types/medicalimage/MedicalImageConstants';

export class DiagnosisService {
  private baseUrl: string = 'http://localhost:8080';
  private httpEngine: http.HttpRequest;

  constructor() {
    this.httpEngine = http.createHttp();
  }

  async uploadImage(imageUri: string, imageType: ImageType, userId: number): Promise<UploadResponse> {
    try {
      const formData = new FormData();
      formData.append('file', imageUri);
      formData.append('imageType', imageType);
      formData.append('userId', userId.toString());

      const response = await this.httpEngine.request(
        this.baseUrl + API_ENDPOINTS.UPLOAD,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'multipart/form-data'
          },
          extraData: formData,
          connectTimeout: 60000,
          readTimeout: 60000
        }
      );

      const result = JSON.parse(response.result as string);
      if (result.code === 200) {
        return result.data as UploadResponse;
      } else {
        throw new Error(result.message);
      }
    } catch (error) {
      throw new Error('影像上传失败: ' + error.message);
    }
  }

  async analyzeImage(imageId: string, imageType: ImageType, userId: number): Promise<AnalyzeResponse> {
    try {
      const response = await this.httpEngine.request(
        this.baseUrl + API_ENDPOINTS.ANALYZE,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json'
          },
          extraData: {
            imageId: imageId,
            imageType: imageType,
            userId: userId
          },
          connectTimeout: 30000,
          readTimeout: 30000
        }
      );

      const result = JSON.parse(response.result as string);
      if (result.code === 200) {
        return result.data as AnalyzeResponse;
      } else {
        throw new Error(result.message);
      }
    } catch (error) {
      throw new Error('AI分析失败: ' + error.message);
    }
  }

  async getResult(resultId: string): Promise<DiagnosisResult> {
    try {
      const response = await this.httpEngine.request(
        this.baseUrl + API_ENDPOINTS.GET_RESULT + '/' + resultId,
        {
          method: http.RequestMethod.GET,
          connectTimeout: 10000,
          readTimeout: 10000
        }
      );

      const result = JSON.parse(response.result as string);
      if (result.code === 200) {
        return result.data as DiagnosisResult;
      } else {
        throw new Error(result.message);
      }
    } catch (error) {
      throw new Error('获取结果失败: ' + error.message);
    }
  }

  async getLesionDetail(lesionId: string): Promise<Lesion> {
    try {
      const response = await this.httpEngine.request(
        this.baseUrl + API_ENDPOINTS.GET_LESION + '/' + lesionId,
        {
          method: http.RequestMethod.GET,
          connectTimeout: 10000,
          readTimeout: 10000
        }
      );

      const result = JSON.parse(response.result as string);
      if (result.code === 200) {
        return result.data as Lesion;
      } else {
        throw new Error(result.message);
      }
    } catch (error) {
      throw new Error('获取病灶详情失败: ' + error.message);
    }
  }

  destroy() {
    this.httpEngine.destroy();
  }
}

export default new DiagnosisService();
