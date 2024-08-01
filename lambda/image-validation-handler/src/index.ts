import {
  SnsEventTypes,
  ImageMetaDataDto,
  ValidationInfo,
} from "../../shared/types";

const IMAGE_MAX_SIZE = 5 * 1024 * 1024;

export const bytesToMegabytes = (bytes: number): number => {
  return bytes / (1024 * 1024);
};

type HandlerResponse = {
  validation: ValidationInfo;
  metaData: ImageMetaDataDto;
};

export const handler = async (
  event: ImageMetaDataDto
): Promise<HandlerResponse> => {
  try {
    const validationPassed = (event?.fileSize || 0) < IMAGE_MAX_SIZE;

    const message = validationPassed
      ? "Validation passed successfully."
      : `The uploaded image cannot be larger than ${bytesToMegabytes(
          IMAGE_MAX_SIZE
        )}MB.`;

    const result = {
      metaData: event,
      validation: {
        type: SnsEventTypes.IMAGE_VALIDATION_ERROR,
        validationPassed,
        imageName: event.imageKey,
        message,
        userName: event.userName,
      },
    };

    return result;
  } catch (error) {
    throw new Error(`Error processing image: ${error}`);
  }
};
