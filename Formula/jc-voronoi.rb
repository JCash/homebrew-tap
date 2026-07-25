class JcVoronoi < Formula
  desc "Fast C header-only library for creating 2D Voronoi diagrams"
  homepage "https://github.com/JCash/voronoi"
  url "https://github.com/JCash/voronoi/archive/refs/tags/v0.10.1.tar.gz"
  sha256 "c1954f9818d03f593b916d5a117bf8ba45b0ee60de26be908558c44a2677520e"
  license "MIT"

  def install
    include.install "src/jc_voronoi.h", "src/jc_voronoi_clip.h"
  end

  test do
    (testpath/"test.c").write <<~C
      #define JC_VORONOI_IMPLEMENTATION
      #include <jc_voronoi.h>

      int main(void) {
        const jcv_point points[] = {{0.0f, 0.0f}, {1.0f, 1.0f}};
        jcv_diagram diagram = {0};
        jcv_diagram_generate(2, points, 0, 0, &diagram);
        const int success = diagram.numsites == 2;
        jcv_diagram_free(&diagram);
        return success ? 0 : 1;
      }
    C
    system ENV.cc, "test.c", "-std=c99", "-I#{include}", "-o", "test", "-lm"
    system "./test"
  end
end
