import { handleErrors } from "../../shared/utils/handle-errors";
import { SnsImageUploadDto, SnsEventTypes } from "../../shared/types";
import { publishToSns } from "./utils/sns-publish";

export const handler = async (event: SnsImageUploadDto) => {
  try {
    await publishToSns<SnsEventTypes, SnsImageUploadDto>(event.type, {
      userName: event.userName,
      message: event.message,
      imageName: event.imageName,
      type: event.type,
    });
  } catch (error) {
    handleErrors(error);
  }
};
