package com.example.bmw_catalog_service.car;

import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@RestController
@RequestMapping("/api/cars")
@CrossOrigin(origins = "*") // local testing; removed once nginx proxies /api
public class CarController {

    private final CarRepository repo;

    public CarController(CarRepository repo) {
        this.repo = repo;
    }

    @GetMapping
    public List<Car> list(@RequestParam(required = false) String series) {
        return (series == null) ? repo.findAll() : repo.findBySeriesIgnoreCase(series);
    }

    @GetMapping("/{id}")
    public Car get(@PathVariable Long id) {
        return repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND));
    }

    @PostMapping
    public ResponseEntity<Car> create(@Valid @RequestBody CarRequest req) {
        Car c = new Car();
        apply(c, req);
        return ResponseEntity.status(HttpStatus.CREATED).body(repo.save(c));
    }

    @PutMapping("/{id}")
    public Car update(@PathVariable Long id, @Valid @RequestBody CarRequest req) {
        Car c = get(id);
        apply(c, req);
        return repo.save(c);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Long id) {
        if (!repo.existsById(id)) throw new ResponseStatusException(HttpStatus.NOT_FOUND);
        repo.deleteById(id);
    }

    private void apply(Car c, CarRequest r) {
        c.setModelName(r.modelName());
        c.setSeries(r.series());
        c.setBodyType(r.bodyType());
        c.setFuelType(r.fuelType());
        c.setModelYear(r.modelYear());
        c.setHorsepower(r.horsepower());
        c.setPrice(r.price());
        c.setDescription(r.description());
        c.setImageUrl(r.imageUrl());
    }
}
