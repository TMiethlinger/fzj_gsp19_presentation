double calc_area(hpx::shared_future<double> future_r, hpx::shared_future<double> future_pi)
{
    double r = future_r.get();
    double pi = future_pi.get();
    return r * r * pi;
}

int hpx_main(variables_map& vm)
{
    hpx::shared_future<double> future_r = hpx::make_ready_future(vm["r"].as<double>());
    hpx::shared_future<double> future_pi = hpx::async([](){ return 4.0 * atan(1.0); });
    hpx::future<double> future_area = hpx::dataflow(&calc_area, future_r, future_pi);
    return hpx::finalize(); // Area <- future_area.get()
}

int main(int argc, char * argv[])
{
    options_description od;
    od.add_options()("r", value<double>()->default_value(1.0), "Radius: r");
    return hpx::init(od, argc, argv);
