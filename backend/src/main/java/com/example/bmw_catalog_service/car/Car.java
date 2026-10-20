package com.example.bmw_catalog_service.car;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "cars")
public class Car {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "model_name", nullable = false)
    private String modelName;

    @Column(nullable = false)
    private String series;

    @Column(name = "body_type")
    private String bodyType;

    @Column(name = "fuel_type")
    private String fuelType;

    @Column(name = "model_year")
    private Integer modelYear;

    private Integer horsepower;

    @Column(nullable = false)
    private BigDecimal price;

    private String description;

    @Column(name = "image_url")
    private String imageUrl;

    @Column(name = "created_at", insertable = false, updatable = false)
    private LocalDateTime createdAt;

    public Long getId() { return id; }
    public String getModelName() { return modelName; }
    public void setModelName(String v) { this.modelName = v; }
    public String getSeries() { return series; }
    public void setSeries(String v) { this.series = v; }
    public String getBodyType() { return bodyType; }
    public void setBodyType(String v) { this.bodyType = v; }
    public String getFuelType() { return fuelType; }
    public void setFuelType(String v) { this.fuelType = v; }
    public Integer getModelYear() { return modelYear; }
    public void setModelYear(Integer v) { this.modelYear = v; }
    public Integer getHorsepower() { return horsepower; }
    public void setHorsepower(Integer v) { this.horsepower = v; }
    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal v) { this.price = v; }
    public String getDescription() { return description; }
    public void setDescription(String v) { this.description = v; }
    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String v) { this.imageUrl = v; }
    public LocalDateTime getCreatedAt() { return createdAt; }
}
