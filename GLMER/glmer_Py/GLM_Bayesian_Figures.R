library(readxl)
library(dplyr)
library(tidyr)
library(ggplot2)
library(patchwork)

# ── 0. Helper ─────────────────────────────────────────────────────────────────

make_figure <- function(glmer_file, sim_file, title_str, grayscale = FALSE,
                        label_type  = "Type frequency",
                        label_token = "Token frequency",
                        label_ci    = "GLMER 95% CI") {
  
  df_glmer <- read_excel(glmer_file)
  
  df_wide <- df_glmer %>%
    pivot_wider(
      id_cols    = Suffix,
      names_from = Property,
      values_from = c(`Mean intercept`, `CI low`, `CI High`)
    )
  
  df_sim <- read_excel(sim_file, sheet = "Tests")
  
  df_lex <- df_sim %>%
    pivot_wider(
      id_cols    = Class,
      names_from = Property,
      values_from = c(Lexical_p0, Token_p0)
    ) %>%
    rename(Suffix = Class)
  
  df_plot <- left_join(df_wide, df_lex, by = "Suffix")
  
  suffix_order <- c("aF", "iF", "iN", "isM", "maN", "oN", "osM")
  df_plot <- df_plot %>%
    mutate(Suffix = factor(Suffix, levels = suffix_order))
  
  if (grayscale) {
    rect_fill  <- "gray60"
    col_type   <- "gray20"
    col_token  <- "gray70"
  } else {
    rect_fill  <- "#e41a1c"
    col_type   <- "#1f78b4"
    col_token  <- "#33a02c"
  }
  
  p <- ggplot(df_plot) +
    
    geom_rect(
      aes(
        xmin = `CI low_APU`,  xmax = `CI High_APU`,
        ymin = `CI low_PU`,   ymax = `CI High_PU`,
        fill = label_ci
      ),
      alpha = 0.5, color = NA
    ) +
    
    geom_point(
      aes(x = Lexical_p0_APU, y = Lexical_p0_PU,
          color = label_type, shape = label_type),
      size = 3
    ) +
    
    geom_point(
      aes(x = Token_p0_APU, y = Token_p0_PU,
          color = label_token, shape = label_token),
      alpha = 0.5, size = 3
    ) +
    
    scale_fill_manual(
      name   = NULL,
      values = setNames(rect_fill, label_ci)
    ) +
    
    scale_color_manual(
      name   = NULL,
      values = c(setNames(col_type,  label_type),
                 setNames(col_token, label_token)),
      breaks = c(label_type, label_token)
    ) +
    
    scale_shape_manual(
      name   = NULL,
      values = c(setNames(16, label_type),
                 setNames(17, label_token)),
      breaks = c(label_type, label_token)
    ) +
    guides(
      fill  = guide_legend(order = 1),
      color = guide_legend(order = 2),
      shape = guide_legend(order = 2)
    ) +
    
    facet_wrap(~ Suffix, ncol = 4) +
    
    scale_x_continuous(limits = c(-0.1, 1.1), breaks = seq(0, 1, by = 0.2)) +
    scale_y_continuous(limits = c(-0.1, 1.1), breaks = seq(0, 1, by = 0.2)) +
    
    coord_fixed(ratio = 1) +
    
    labs(x = "APU", y = "PU", title = title_str) +
    
    theme_bw(base_size = 11) +
    theme(
      plot.title       = element_text(size = 16, face = "bold", hjust = 0.5),
      axis.title       = element_text(size = 14, face = "bold"),
      axis.text        = element_text(size = 8),
      strip.text.x     = element_text(size = 14, face = "bold"),
      strip.text.y     = element_text(size = 14, face = "bold"),
      strip.background = element_rect(fill = "gray95", color = "gray70"),
      panel.grid.major = element_line(color = "gray90"),
      panel.grid.minor = element_line(color = "gray95"),
      panel.border     = element_rect(color = "black", fill = NA, linewidth = 0.5),
      panel.spacing    = unit(4, "mm"),
      text             = element_text(family = "sans"),
      legend.position  = "bottom",
      legend.text      = element_text(size = 10),
      legend.key.size  = unit(5, "mm")
    )
  
  return(p)
}

# ── 1–4. Loop over colour and grayscale 

for (gs in c(FALSE, TRUE)) {
  
  suffix <- if (gs) "_grayscale" else "_color"
  
  # ── Adults ──────────────────────────────────────────────────────────────────
  
  p_adults <- make_figure(
    glmer_file  = "GLM_Adults_intercept_probabilities.xlsx",
    sim_file    = "ForSimulation_Adults_With_Tokens.xlsx",
    title_str   = "Adults - GLMER CIs with type and token probability values",
    grayscale   = gs,
    label_type  = "GreekLex 2 type frequency",
    label_token = "HNC Golden token frequency",
    label_ci    = "GLMER 95% CI"
  )
  
  ggsave(paste0("GLM_Figure_Adults", suffix, ".pdf"), p_adults,
         width = 10, height = 5.5, device = cairo_pdf)
  ggsave(paste0("GLM_Figure_Adults", suffix, ".jpg"), p_adults,
         width = 10, height = 5.5, dpi = 300)
  
  # ── Grade 3 
  
  p_grade3 <- make_figure(
    glmer_file  = "GLM_GradeC_intercept_probabilities.xlsx",
    sim_file    = "ForSimulation_Grade3_with_Tokens.xlsx",
    title_str   = "Grade 3 - GLMER CIs with type and token probability values",
    grayscale   = gs,
    label_type  = "HelexKids 2.0 type frequency",
    label_token = "HelexKids 2.0 token frequency",
    label_ci    = "GLMER 95% CI"
  )
  
  # ── Grade 6 
  
  p_grade6 <- make_figure(
    glmer_file  = "GLM_GradeF_intercept_probabilities.xlsx",
    sim_file    = "ForSimulation_Grade6_with_Tokens.xlsx",
    title_str   = "Grade 6 - GLMER CIs with type and token probability values",
    grayscale   = gs,
    label_type  = "HelexKids 2.0 type frequency",
    label_token = "HelexKids 2.0 token frequency",
    label_ci    = "GLMER 95% CI"
  )
  
  # ── Combine Grade 3 + Grade 6 with single legend at bottom 
  
  p_combined <- (p_grade3 / p_grade6) +
    plot_layout(guides = "collect") +
    plot_annotation(
      tag_levels = "a",
      tag_prefix = "(",
      tag_suffix = ")",
      theme = theme(plot.tag = element_text(size = 16, face = "bold"))
    ) &
    theme(legend.position = "bottom")
  
  ggsave(paste0("GLM_Figure_Children", suffix, ".pdf"), p_combined,
         width = 10, height = 11, device = cairo_pdf)
  ggsave(paste0("GLM_Figure_Children", suffix, ".jpg"), p_combined,
         width = 10, height = 11, dpi = 300)
}

message("All done.")