export interface ProductMetadataRequest {
  productName: string;
  category: string;
  price: number;
  variants?: Array<{ type: string; options: string[] }>;
}

export interface ProductMetadata {
  description: string;
  tags: string[];
  suggestedCaptions: string[];
}

export interface DailyPlanProductInput {
  name: string;
  category?: string;
  stock?: number | null;
  imageUrl?: string;
}

export interface DailyPlanRequest {
  businessCategory: string;
  festival?: string;
  products: DailyPlanProductInput[];
  date: string;
}

export interface DailyPlanResponse {
  title: string;
  reason: string;
  captionIdea: string;
  callToAction: string;
  suggestedProductName?: string;
  suggestedProductImageUrl?: string;
  festivalTag?: string;
}
