************************************
* IMPORTANT NOTICE FOR ALL SCRIPTS *
************************************

All scripts in this pipeline are currently in bash format. If you wish to run them using sbatch, you must first edit the "SBATCH Insert" file for your particular HPC (including account and other info), and then insert that at the top of every script, just after the line #!/bin/bash; furthermore, the SBATCH Insert is not formatted for job arrays at the moment, and none of the scripts are currently formatted for parallel execution in this version of the pipeline. Some of these scripts will take literally days or weeks to run if run as-is without SBATCH or parallelization, or without sufficient RAM/CPU allocations.

*******************************************
* SECOND IMPORTANT NOTICE FOR ALL SCRIPTS *
*******************************************

This is NOT a fully-automated pipeline. Several steps involve MANUAL CURATION of certain files that cannot be automated, as a human eye must examine some data and make decisions on what to do. Read the following list of Steps carefully with an eye toward these scripts. All such scripts will have MANUAL CURATION in caps in the step instructions.

********************
* PIPELINE DETAILS *
********************

This pipeline was built with both Illumina and PacBio sequencing to be performed at the same time. If you do not need Illumina processing, you can skip Assembly steps 4-9. If you do not need PacBio processing, you can skip Assembly step 10. Note that this separation only applies during Assembly. Once you have entered Annotation, all scripts are pluripotent for both Illumina or PacBio assemblies.

*****************
* Initial Setup *
*****************

Step One
	Clone this pipeline from the github into a project directory of your choosing. This directory must have a minimum of 1TB (preferably 2TB) of available space to hold everything needed for the pipeline. This will include multiple copies of your genome files, as they move about the various steps. The folder where you copied the git will be considered BASE_DIR going forward. Locate the cloned Scripts folder, and use either the config.sh (reviewers) or config.template (future users) to configure the pipeline. Instructions are within the template for how to edit it. You can always re-clone the pipeline into a new project name for future runs.

Step Two
	Run the scripts 0-0.ReferenceRetriever.sh and 0-1.RawFilePrep.sh before any other step, but after having configured your config.sh. If you do not provide a list of references and isolates to the config.sh file, these first two scripts will fail to execute. Note that all isolates must have unique names with no spaces; this includes if you have two versions of the same isolate, be sure to give them unique names.

Step Three
    Install the various conda packages using the environment.yml files in the Environments folder. Some of the software will require configuration, database downloads, or a license to use. If you are a reviewer who doesn't intend to actually run but only review the pipeline, you will not need to do any of this. However, any future user running the pipeline on their own data will need to follow the instructions from each piece of software to download their respective databases, and configurations.

******************
* ASSEMBLY STEPS *
******************

Step Four (CLC Genomics Workbench) ILLUMINA STEP
	This pipeline was designed with CLC Genomics Workbench as the primary tool used for trimming and for one polishing step. After running script 0-1.RawFilePrep.sh, you must import the raw reads files into CLC Genomics Workbench, use the trim features as described in the paper, and then export the trimmed reads (including orphans) back out into the /Assembly/ExportedTrims folder in fastq format. Note that the naming convention used going forward requires the files you export to be in the format <isolate>_R1.fastq, <isolate>_R2.fastq, and <isolate>_orphans.fastq from this step, and that is not typically the exported name provided by CLC. You will need to manually edit the files in the /ExportedTrims folder to match this pattern.

Step Five (Scripts 1-) ILLUMINA STEP
	Run Scripts in the 1- series, in order. If you skip KrakenSetup, other steps will remind you that you must first run KrakenSetup. This step has been fully automated for ascomycetes, and note that it automatically excludes basidiomycetes and all other non-fungal organisms. If you are running this pipeline on any other organism, you will need to manually edit the list of --taxids to accommodate this.

Step Six (Scripts 2-) ILLUMINA STEP
	Run Scripts in the 2- series, in order. Note that Quast and BUSCO are technically optional steps, but it is a good idea to generate a report for your assemblies at every step in the pipeline so that you can see if anything goes wrong at any point. The values here will improve in later steps, as more polishing and editing are done.

Step Seven (Scripts 3-) ILLUMINA STEP
	Run Scripts in the 3- series, in order. Again, Quast and BUSCO are optional, but helpful steps to include.

Step Eight (CLC Genomics Workbench) ILLUMINA STEP
	Output from Pilon should be imported into CLC Genomics Workbench and polished according to the procedure in the original paper. This extra polishing step is necessary to close scaffold gaps and bridge scaffolds. Export the resulting polished assembly to the /Assembly/Assemblies folder. The exported names MUST contain the name of the isolate, case-sensitive. As long as the exported name contains the case-sensitive isolate name, the 4-0.Assembly_fix.sh script will "fix" the name to match what downstream scripts expect, so no manual editing is necessary this time.

Step Nine (Scripts 4-) ILLUMINA STEP
	Run Scripts in the 4- series, in order. Note that 4-0.Assembly_fix.sh, is designed to take the long, agglutinative names from CLC Genomics Workbench and shorten them to what is expected for the remainder of the downstream pipeline. You can perform this step manually, or if you have many isolates, let the script perform this step automatically for you. If you perform it manually, you can skip 4-0. Likewise, the Quast and BUSCO scripts for this step are also technically optional (making the entire 4- series optional), but highly recommended for troubleshooting/diagnostic purposes.

Step Ten (Scripts 5-) PACBIO STEP
	Run Scripts in the 5- series, in order. There is a MANUAL CURATION required during this step. In particular, you must use the output of the 5-2.AssemblyChars.sh script to determine a list of contigs to exclude from the assembly (owing to being mitochondrial, chloroplast, or rDNA clusters) to feed into the 5-3.SeqKit.sh script. This will require you to insert this list of contigs (space separated, no commas), into the echo " " command, between the double quotes. Note that you should copy this basic command once for each of your isolates that you're assembling, and provide each isolate an individualized list of contigs to exclude. There is a further MANUAL CURATION required during this step. After the first tidk search step has completed in 5-4.TIDK.sh, you must decide whether to run the optional portions of the script to cut chimeric contigs. This will only be necessary if you have internal telomeres. Note that script 5-4.TIDK.sh is written as a single script, but it is actually NOT meant to be run as-is. It is meant to be run line-by-line, taking the output from one line to inform and feed into later lines.

*************************
* END OF ASSEMBLY STEPS *
*************************

********************
* ANNOTATION STEPS *
********************

Step Eleven (Scripts 7-) Universal Step
	Run Scripts in the 7- series, in order. The Quast and BUSCO steps are NOT optional on this run. This is the final assembly step/first annotation step, and the most important Quast and BUSCO runs. This will be your "final" Quast and BUSCO steps, and the ones that generate the reportable stats. There is one additional future run, but these are a simple check to verify overmasking did not occur.

Step Twelve (Scripts 8-) Universal Step
	Determine a number of appropriate references for your genus that have available annotated proteomes. Download those proteomes from whatever database source you prefer (NCBI, etc). Manually place proteome files into the /Proteomes subdirectory of the /RawSequences directory. You can place any number of files in this folder, but they MUST be .faa format. This is simply fasta format for amino acids. Run the 8-0.Clean_Proteome.sh script, which will concatenate however many .faa files are in this folder and process them into a usable, clean proteome reference. The script currently has a "default" list of transposons and repetitive element names to extract based on the original run, Colletotrichum; however, if you are running on a different genus or especially anything not fungal, navigate to line 50 of the script and manually edit the long list of names after the grep -Ei command. Be sure to include "OR" symbols between each "|" and enclose the entire list in quotes "".
	Run script 8-1.Clean_Sources.sh. This will create a clean model of the training reference without any transposons or other repetitive elements. As in the step above, a default list of transposons for Colletotrichum is provided; if you need a different list, please manually edit this list with your own, using the same rules as above. Note that the reference must be identified with the TRAINER variable in the config.sh script, and must have an annotated gff3 file in addition to its fasta sequence file. You cannot train the later algorithms without this gff3 file.
	Run script 8-2.EDTA.sh. This will take the output of the previous two scripts as input, and MUST have those inputs in order to do what it does. The script trains an algorithm to recognize the pattern of genes in the target genus and create a repeat model to be used to soft-mask your isolates. This script takes a significant amount of resources and runtime, perhaps the most of any program in this pipeline, and should be run with SBATCH (see instructions above) and a very generous wall time.
	Run script 8-3.RepeatMasker.sh. This will take the output of the above script and soft-mask your isolates and references for gene prediction and annotation.
	Scripts 8-4 and 8-5 are technically optional, but encouraged to use to ensure your BUSCO completeness score doesn't crash as a result of masking. If it does, this is an indication that you have over-masked. If you have over-masked, it is recommended to use a less-stringent masking technique.

Step Thirteen (Scripts 9-) Universal Step
	The first three scripts in this step are technically optional. The three scripts provide RNA annotation. Depending on the goals of your project, you may or may not need these annotations. Funannotate2, later in the pipeline, will initially annotate tRNAs, but gFACs, which follows it, will strip these tRNA annotations. It is recommended to run this step for this reason, as the RNAs can be manually re-combined later. There are no special instructions necessary for these three steps. Script 9-3.rDNAClusterRemover.sh is used explicitly to remove rDNA clusters from PacBio assemblies. It cannot be run without editing the script to accommodate your specific isolates and their specific contigs which you have identified as rDNA clusters. It is included only as a model demonstrating how it was done and how to do it again.

Step Fourteen (Scripts 10-) Universal Step
	Run scripts in the 10- series in order. Note that you MUST provide an entry in the config.sh script for the TRAINING variable, and note that this is different from the TRAINER variable. The TRAINING variable needs a separate entry for each species, whereas the TRAINER variable needed only a single entry per genus. You should always choose your most complete, contiguous, and cleanest reference for this role. Also note that the script is defaulted to running on Colletotrichum; if you are using the pipeline for a different genus, you must change the --busco-lineage and --augustus-species lines. You may either select your own custom entry for these two lines, or you can delete the lines entirely and allow funannotate2 to use its default behavior for these flags. Note that, if you remove the two lines, be sure to remove the \ after the --cpus flag just above them as well. Also note that, like all your isolates and references, whichever species you choose for TRAINING MUST have an entry in the SPECIES_MAP variable as well.
	For script 10-1.Fun2Predict.sh, the default is set up for Colletotrichum. If you are customizing this pipeline for a different genus, you must edit the if statements to indicate your specific species; you need a separate if or elif command for each species you are using, following the format provided as a model in the script. The species listed should be in the order they are listed in the TRAINING variable so the indexing can identify each species name to each index position.

Step Fifteen (Scripts 11-) Universal Step
	Run scripts in the 11- series in order. Note that 11-0.gFACs.sh is configured for Colletotrichum as default. If you plan to use this pipeline for any other genus, you should reconfigure the --min-exon-size, --min-intron-size, and --min-CDS-size flags as appropriate for your genus. All other settings should be universal.

Step Sixteen (Scripts 12-) Universal Step
	Run scripts in the 12- series in order. Note that some of these scripts will execute rather quickly, but 12-0.antiSMASH.sh and 12-2.InterProScan.sh may need more resources. In fact, 12-2.InterProScan.sh is perhaps the most resource-intensive tool used in this pipeline, in competition with EDTA, especially if you're running a large number of isolates. I recommend using SBATCH at the very least, and it's highly encouraged to edit the script to use parallelization, the instructions for which are beyond the scope of this document.

Step Seventeen (Scripts 13-) Universal Step
	Run scripts in the 13- series in order. Note that script 13-0.F2A.sh is NOT optional. If you attempt to run 13-1.Fun2Annotate.sh before the editing done by F2A takes place, that script will fail, but will not give you error messages - it will simply output a "bad" file without telling you. This will complicate your downstream processing and analysis greatly.

***************************
* END OF ANNOTATION STEPS *
***************************

Notes - Please note that additional scripts are provided for optional and analytical steps. All scripts in the X- series were used in the original pipeline to edit out a contaminant found in one specific isolate. They are not necessary unless you specifically locate a large contaminant in one of your isolates, and then can be emulated as a model for how to remove that contaminant. They are not, however, "ready-to-run" out of the box. They are highly specific to that one isolate and removing that specific contaminant, with its unique characteristics. Likewise, the P- series of scripts were used to generate phylogenetic trees after the pipeline was completed. They are included, again, only as a model for how to replicate this. Some scripts you may also see in the /Scripts folder that have not had instructions to run, such as RepeatContentReporter.sh or DataCompiler.sh were simply analysis tools to automate the process of extracting reportable data from one or another of the various output files. Like with other scripts, these can be used as a model for building your own analysis tools, but they are highly specific to the individual outputs of the original paper and pipeline. Lastly, 14-0.Orthofinder.sh, is an entirely optional script that would be after the technical pipeline itself, but can be useful to emulate for some analytical purposes. It may also be used in future versions of this pipeline as the start of an "expansion" to the capabilities of the pipeline.

***************
* END OF FILE *
***************
