package com.example.bmw_catalog_service.car;

import jakarta.validation.constraints.*;
import java.math.BigDecimal;

public record CarRequest(
        @NotBlank @Size(max = 100) String modelName,
        @NotBlank @Size(max = 50) String series,
        String bodyType,
        String fuelType,
        Integer modelYear,
        @Positive Integer horsepower,
        @NotNull @DecimalMin("0.0") BigDecimal price,
        String description,
        @Size(max = 500) String imageUrl
) {}
