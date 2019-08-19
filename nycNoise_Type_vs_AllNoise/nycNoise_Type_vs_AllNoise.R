# Compare individual types of Noise with total noise

library(data.table)
library(ggplot2)
options(scipen = 100, digits = 10)

noiseType_Year <- fread("noiseType_Year.csv") 

# Compute "All Noise" totals for use in comparison graphs. BEFORE pruning types less than 1% of total as below. Total now 'cos "All Noise" is added as a Complaint.Type and will double total complaints in consideration.
x <- noiseType_Year[, .(Complaint.Type = "All Noise", N = sum(N)), by = Year]

# Omit "Complaint.Type" less than 1% of total. Or whatever percentage.
noiseType_Year <- 
  noiseType_Year[Complaint.Type %in% 
                   noiseType_Year[, sum(N), by = Complaint.Type][order(V1)][cumsum(V1) >= (sum(V1)*.01), ][,Complaint.Type], ]

# Add "All Noise" totals from x above
noiseType_Year <- rbind(noiseType_Year, x)
rm(x)

# Replace "/ " in Complaint.Type "Noise - Street/Sidewalk" ( throws error in ggplot)
noiseType_Year$Complaint.Type <- factor(gsub("/", " or ", noiseType_Year$Complaint.Type))

# PNG loop - compare noise types with All Noise ----

# Need to exclude All Noise vs All Noise in for loop

for (i in unique(noiseType_Year$Complaint.Type)) {
  ggsave(
    paste0("noiseType_", i, "_v_AllNoise.png"),
    ggplot(
      data = noiseType_Year[Complaint.Type == paste0(i, "|All Noise")],
      mapping = aes(x = Year, y = N, group = Complaint.Type)
    ) +
      facet_grid(Complaint.Type ~ ., scale = "free") +
      geom_point(
        data = noiseType_Year[Complaint.Type == i],
        size = 1.5,
        color = "red"
      ) +
      geom_line(data = noiseType_Year[Complaint.Type == i], size = 0.15) +
      geom_smooth(data = noiseType_Year[Complaint.Type == i]) +
      geom_point(
        data = noiseType_Year[Complaint.Type == "All Noise"],
        size = 1.5,
        color = "red"
      ) +
      geom_line(data = noiseType_Year[Complaint.Type == "All Noise"], size = 0.15) +
      geom_smooth(data = noiseType_Year[Complaint.Type == "All Noise"]) +
      labs(
        x = "Year",
        y = "Annual number of complaints",
        title = paste0("Complaints to 311 regarding ", i, ", 2004 to Q2 2019"),
        subtitle = "Compared to total noise complaints of all types. With smoothened trendlines; separate scales."
      ),
    dpi = "retina",
    device = 'png'
  )
}

rm(list = ls())
