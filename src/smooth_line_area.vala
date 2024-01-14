using Cairo;

namespace LiveChart {
     public class SmoothLineArea : SmoothLine {

        public double area_alpha {get; set; default = 0.1;}
        private SmoothLineAreaSerieDrawer drawer = new SmoothLineAreaSerieDrawer();

        public SmoothLineArea(Values values = new Values()) {
            base(values);
        }
        public override void draw(Context ctx, Config config) {
            if (visible) {
                drawer.draw(ctx, config, this.line, Points.create(values, config),this.main_color, this.area_alpha, this.region);
            }
        }
    }

    public class SmoothLineAreaSerieDrawer {

        private RegionAreaDrawer region_drawer = new RegionAreaDrawer();
        private RegionOnLineDrawer region_on_line_drawer = new RegionOnLineDrawer();
        private SmoothLineDrawer smooth_line_drawer = new SmoothLineDrawer();

        public void draw(Context ctx, Config config, Path line, Points points, Gdk.RGBA color, double alpha, Region? region) {
            if(points.size > 0) {
                var intersections = smooth_line_drawer.draw(ctx, config, line, points, region);
                var curve = ctx.copy_path();
                
                if(region != null && region.has_line_color()) {
                    ctx.push_group();
                        ctx.stroke();

                        ctx.set_operator(Operator.IN);
                        region_on_line_drawer.draw(ctx, config, intersections);
                        ctx.fill();
                    ctx.pop_group_to_source();
                    ctx.paint();
                } else {
                    ctx.stroke();
                }

                ctx.push_group();
                    ctx.append_path(curve);
                    var area = new Area(points, color, alpha);
                    area.draw(ctx, config);
                    ctx.fill();
   
                    // Clear pixels that overlaps existing path
                    ctx.append_path(curve);
                    ctx.set_operator(Operator.CLEAR);
                    ctx.stroke();

                    if (region != null && region.has_area_color()) {

                        // Clear existing area if regions
                        ctx.set_operator(Operator.CLEAR);
                        region_drawer.draw(ctx, config, intersections);
                    }

                ctx.pop_group_to_source();
                ctx.paint();
       
                if (region != null && region.has_area_color()) {
                    ctx.push_group();
                        //Create a clip to match the region area only, without the line
                        ctx.append_path(curve);
                        area.draw(ctx, config);
                        ctx.clip();
    
                        region_drawer.draw(ctx, config, intersections);
                        
                        ctx.append_path(curve);
                        ctx.set_operator(Operator.CLEAR);
                        ctx.stroke();
    
                        ctx.pop_group_to_source();
                        
                    ctx.paint();
                }
            }
        }
    }

    public class RegionAreaDrawer {
        public void draw(Context ctx, Config config, Intersections intersections) {
            var boundaries = config.boundaries();
            intersections.foreach((intersection) => {
                if (intersection != null) {
                    ctx.set_source_rgba(intersection.region.area_color.red, intersection.region.area_color.green, intersection.region.area_color.blue, intersection.region.area_color.alpha);
                    ctx.rectangle(intersection.start_x, boundaries.y.min, intersection.end_x - intersection.start_x, boundaries.height);
                }
                return true;
            });
            ctx.fill();
        }
    }
}