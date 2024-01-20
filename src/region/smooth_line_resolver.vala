using Cairo;

namespace LiveChart {

    public class SmoothLineRegionResolver : RegionResolver, Object {
        private WaterlineRegionResolver resolver;
        private Region region;
        private Intersections intersections = new Intersections();

        public SmoothLineRegionResolver(Region region) {
            this.region = region;
            this.resolver = new WaterlineRegionResolver(region.floor, region.ceil);
        }

        public Region get_region() {
            return region;
        }

        public Intersections get_intersections() {
            return intersections;
        }

        public void resolve(Point previous, Point current, GetIntersection get_intersection) {
            if (resolver.has_at_least_one_point_within(previous, current)) {

                if (resolver.is_entering_by_the_bottom(previous, current)) {

                    var entered_at = region.floor;
                    var coords = get_intersection(entered_at);

                    if (coords != null) {
                        if(intersections.has_an_opened_intersection()) {
                            intersections.update(current.x);
                        } else {
                            intersections.open(region, coords.x, entered_at);
                        }
                    }
                }
                if (resolver.is_entering_by_the_top(previous, current)) {
                    
                    var entered_at = region.ceil;
                    var coords = get_intersection(entered_at);
           
                    if (coords != null) {
                        if(intersections.has_an_opened_intersection()) {
                            intersections.update(current.x);
                        } else {
                            intersections.open(region, coords.x, entered_at);
                        }
                    }
                }

                if (resolver.is_leaving_by_the_top(previous, current)) {

                    var exited_at = region.ceil;
                    var coords = get_intersection(exited_at);

                    if (coords != null) {
                        if(intersections.has_an_opened_intersection()) {
                            intersections.close(coords.x, exited_at);
                        } else {
                            intersections.open_without_entrypoint(region, previous.x);
                            intersections.close(coords.x, exited_at);
                        }
                    }
                }
                if (resolver.is_leaving_by_the_bottom(previous, current)) {

                    var exited_at = region.floor;
                    var coords = get_intersection(exited_at);

                    if (coords != null) {
                        if(intersections.has_an_opened_intersection()) {
                            intersections.close(coords.x, exited_at);
                        } else {
                            intersections.open_without_entrypoint(region, previous.x);
                            intersections.close(coords.x, exited_at);
                        }
                    }
                }
                if(resolver.is_within(previous, current)) {
                    
                    if(!intersections.has_an_opened_intersection()) {
                        intersections.open_without_entrypoint(region, previous.x);
                    } else {
                        intersections.update(current.x);
                    }
                }
            }
        }
    }

    public class WaterlineRegionResolver {
        private double floor;
        private double ceil;

        public WaterlineRegionResolver(double floor, double ceil) {
            this.floor = floor;
            this.ceil = ceil;
        }

        public bool has_at_least_one_point_within(Point previous, Point current) {
            return previous.data.value  > this.floor && previous.data.value  <= this.ceil || current.data.value > this.floor && current.data.value <= this.ceil;
        }

        public bool is_entering_by_the_bottom(Point previous, Point current) {
            return previous.data.value < this.floor && current.data.value >= this.floor && current.data.value < this.ceil;
        }

        public bool is_entering_by_the_top(Point previous, Point current) {
            return previous.data.value >= this.ceil && current.data.value < this.ceil;
        }

        public bool is_leaving_by_the_top(Point previous, Point current) {
            return previous.data.value >= this.floor && previous.data.value < this.ceil && current.data.value  > this.ceil;
        }

        public bool is_leaving_by_the_bottom(Point previous, Point current) {
            return previous.data.value >= this.floor && current.data.value < this.floor;
        }

        public bool is_within(Point previous, Point current) {
            return previous.data.value >= this.floor && current.data.value >= this.floor && previous.data.value < this.ceil && current.data.value < this.ceil ;
        }
    }
}