class JcVoronoi < Formula
  desc "Fast C header-only library for creating 2D Voronoi diagrams"
  homepage "https://jcash.github.io/voronoi/"
  url "https://github.com/JCash/voronoi/archive/refs/tags/v0.10.1.tar.gz"
  sha256 "c1954f9818d03f593b916d5a117bf8ba45b0ee60de26be908558c44a2677520e"
  license "MIT"
  revision 1

  depends_on "cmake" => :build

  def install
    # v0.10.1 predates JC_VORONOI_VERSION, so normalize its project version here.
    if version.to_s == "0.10.1"
      inreplace "CMakeLists.txt", /project\(jc_voronoi VERSION [^)]+ LANGUAGES C\)/,
                "project(jc_voronoi VERSION #{version} LANGUAGES C)"
    end

    system "cmake", "-S", ".", "-B", "build", "-DJC_VORONOI_VERSION=#{version}", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    cmake_package = lib/"cmake/jc_voronoi"
    assert_path_exists cmake_package/"jc_voronoiConfig.cmake"
    assert_path_exists cmake_package/"jc_voronoiConfigVersion.cmake"
    assert_path_exists cmake_package/"jc_voronoiTargets.cmake"
    assert_match version.to_s, (cmake_package/"jc_voronoiConfigVersion.cmake").read

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
