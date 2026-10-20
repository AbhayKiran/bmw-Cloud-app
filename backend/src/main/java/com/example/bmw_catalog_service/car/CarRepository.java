package com.example.bmw_catalog_service.car;

import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface CarRepository extends JpaRepository<Car, Long> {
    List<Car> findBySeriesIgnoreCase(String series);
}
