gqs_light <- function(stanc_ret) {
  gqs <- c(
  "(Rcpp::NumericMatrix draws) {",
      "std::vector<std::string> param_names;",
      "constrained_param_names(param_names, false, true);",
      "std::vector<std::string> gq_names = param_names;",
      "size_t upper_bound = param_names.size();",
      "param_names.clear();",
      "constrained_param_names(param_names, false, false);",
      "size_t lower_bound = param_names.size();",
      "size_t num_gqs = upper_bound - lower_bound;",
      "std::vector<std::vector<size_t> > param_dimss;",
      "get_dims(param_dimss); // does this include lp__?",
      "param_dimss.erase(param_dimss.begin() + lower_bound, param_dimss.end());",
      "gq_names.erase(gq_names.begin(), gq_names.begin() + lower_bound);",

      "std::vector<int> dummy_params_i;",
      "std::vector<double> unconstrained_params_r;",
      "std::vector<double> gqs;",
      "std::vector<double> draws_i(draws.cols());",
      "std::stringstream msg;",
      "Rcpp::NumericMatrix output(draws.rows(), num_gqs);",
      "Rcpp::CharacterVector cn(num_gqs);",
      "for (size_t j = 0; j < num_gqs; ++j)",
        "cn(j) = gq_names[j];",
      "Rcpp::colnames(output) = cn;",
      
      "for (size_t i = 0; i < draws.rows(); ++i) {",
        "dummy_params_i.clear();",
        "unconstrained_params_r.clear();",
        "for (size_t j = 0; j < draws_i.size(); j++)",
          "draws_i[j] = draws(i, j);",
        "try {",
          "stan::io::array_var_context context(param_names, draws_i,",
                                              "param_dimss);",
          "transform_inits(context, dummy_params_i, unconstrained_params_r,",
                          "&msg);",
        "} catch (const std::exception& e) {",
          "throw std::runtime_error(e.what());",
        "}",
        "if (i % 100 == 0) Rcpp::checkUserInterrupt();",
        "write_array<boost_random_R>(base_rng__, unconstrained_params_r,",
                                    "dummy_params_i, gqs, false, true, pstream__);",
        "for (size_t j = 0; j < num_gqs; j++)",
          "output(i, j) = gqs[j];",
      "}",
      "return output;",
    "}")
  
  stanc_ret_ <- doctor_cppcode(stanc_ret, use_R_PRNG = TRUE, use_Rcout = TRUE,
                               detemplate = TRUE, double_only = TRUE, propto__ = TRUE,
                               make_data_public = FALSE, drop_Eigen = TRUE,
                               drop_log_prob = TRUE, drop_model_header = TRUE,
                               return_names = TRUE, return_dims = TRUE, 
                               add_methods = list(gqs = gqs),
                               methods_for_user_defined_functions = TRUE)
  out <- exposeStanClass(stanc_ret_, field_access = "read_write")
  return(out)
}
