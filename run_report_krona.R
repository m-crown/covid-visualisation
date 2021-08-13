#!/usr/local/bin/Rscript

library(stringr)
library(optparse)

option_list = list(
  make_option(c("-f", "--file"), type="character", default=NULL, 
              help="Sequencing run lineage report output - should contain taxon, lineage and note fields as minimum.", metavar="character"),
  make_option(c("-r", "--run_name"), type="character", default="krona_run_report.html",
              help="output file name [default= %default]", metavar="character")
); 

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);


#Import the lineage report from Pangolin. 
lineage_file <- read.csv(opt$file, header = TRUE)

#Extract the COG/Sample codes from the taxon field.
lineage_file$sample <- str_extract_all(lineage_file$taxon, "(?<=Consensus_).*?(?=\\.)")
lineage_file$sample <- unlist(lineage_file$sample)

#Create a column for Krona plot containing the fine
lineage_file$lineage_output <- ifelse(lineage_file$lineage == "None", lineage_file$note, lineage_file$lineage)
lineage_file$num <- 1 #Assigning a quantity to each sample of 1 to reflect total quantities in Krona plot.
krona_format <- lineage_file[, c("num", "status", "lineage_output", "sample")] #making a new df with just cols krona needs in the correct order for plotting. 
write.table(krona_format,"krona_formatted_run.tsv", sep = "\t", col.names = FALSE, quote = FALSE, row.names = FALSE) #krona requires a tabulated file without any headers


system(paste0("ktImportText krona_formatted_run.tsv -o ", opt$run_name, ".html")) #execute the kronatools command.
system("rm krona_formatted_run.tsv") #remove the temp file krona uses to produce html output.  

write(paste0("Saved Krona chart to ", opt$run_name, ".html"), stdout())
