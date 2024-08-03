export interface HttpError extends Error {
  status?: number;
}

export enum SnsEventTypes {
  IMAGE_CREATED = "IMAGE_CREATED",
  IMAGE_VALIDATION_ERROR = "IMAGE_VALIDATION_ERROR",
}

export type ImageValidationErrorDto = {
  userName: string;
  validationMsg: string;
  imageName: string;
};

export type ImageMetaDataEventMap = Record<
  SnsEventTypes.IMAGE_CREATED,
  ImageMetaDataDto
>;
export interface SnsEvent<T = unknown, U = unknown> {
  eventType: T;
  data: U;
  timestamp: number;
}

export type ImageUploadData = {
  bucket: string;
  key: string;
  userName: string;
  fileSize: number;
};

export type SnsImageUploadDto = {
  type: SnsEventTypes;
  message: string;
  userName: string;
  imageName: string;
};

export type ValidationInfo = {
  type: SnsEventTypes;
  message: string;
  validationPassed: boolean;
};

export type ImageMetaDataItem = {
  userName: string;
  imageKey: string;
  imageName: string;
  imageBucket: string;
  timestamp: number;
  imageId?: string;
};

export type ImageMetaDataDto = {
  userName: string;
  imageKey: string;
  imageBucket: string;
  fileSize?: number;
};
