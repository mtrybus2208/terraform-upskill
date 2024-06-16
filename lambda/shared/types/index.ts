export interface HttpError extends Error {
  status?: number;
}

export enum SnsEventTypes {
  IMAGE_CREATED = "IMAGE_CREATED",
}

export type ImageMetaDataDto = {
  userName: string;
  imageKey: string;
  imageName: string;
};

export type ImageMetaDataItem = {
  userName: string;
  imageKey: string;
  imageName: string;
  imageBucket: string;
  imageId: string;
  timestamp: number;
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
