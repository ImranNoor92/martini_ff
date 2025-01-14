#Step 1: Clone the MARTINI Repository
git clone https://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@github.com/ImranNoor92/martini_ff.git
#Purpose: Clones the MARTINI repository from GitHub using your personal access token (PAT) for authentication.
#Result: A new folder named `martini_ff` is created, containing the MARTINI files.

#Steo 2: Create and Navigate to the Working Directory
mkdir martini_tutorial
cd martini_tutorial/
#Purpose: Creates a new directory named `martini_tutorial` and navigates into it.
#Step 3: Download the Protein Structure File
wget http://www.rcsb.org/pdb/files/181L.pdb
#Purpose: Downloads the protein structure file `181L.pdb` from the Protein Data Bank (PDB).
#Step 4: Clean the Protein Structure File
grep "^ATOM" 181L.pdb > 181L_clean.pdb
#Purpose: Extracts only the atomic coordinates (`ATOM` lines) from the `181L.pdb` file, removing any irrelevant information (e.g., HETATM, CONECT lines).
#Step 5: 
sudo apt update
sudo apt install python3-pip
pip3 --version
pip install vermouth
#Purpose: Installs the Python package manager `pip` and the `vermouth` package for MARTINI force field parameterization.
#Step 6: Install Martinize2 Using Vermouth.
pip install git+https://github.com/marrink-lab/vermouth-martinize.git#vermouth
#Purpose: Installs the MARTINI2 tool `vermouth-martinize` using the `vermouth` package.
#Step 7: Add `martinize2` to PATH
nano ~/.bashrc
export PATH=$PATH:~/.local/bin
source ~/.bashrc
#Purpose: Adds the `martinize2` executable to the system PATH for easy access. 
#Step 8: Test `martinize2`
martinize2 -h
#Purpose: Checks if the `martinize2` tool is successfully installed and accessible.
#step 9: Coarse-Grain the Protein
martinize2 -f 181L_clean.pdb -o t4l_only.top -x t4l_cg.pdb -p backbone -ff martini3001
# Purpose: Converts the all-atom protein structure into a coarse-grained MARTINI-compatible structure.
#   -f 181L_clean.pdb: Input cleaned PDB file.
#   -o t4l_only.top: Outputs the topology file for the coarse-grained protein.
#   -x t4l_cg.pdb: Outputs the coarse-grained structure file.
#   -p backbone: Treats the protein backbone with default MARTINI parameters.
#   -ff martini3001: Specifies the MARTINI 3.0.0 force field.
# Result: Generates the coarse-grained files.
#Step 10: Clone the DSSP Repository
git clone https://github.com/cmbi/dssp.git
cd dssp
./autogen.sh
./configure
make
sudo apt install dssp
dssp --version
# Purpose: Compiles DSSP from source using the Autotools build system.
#   ./autogen.sh: Prepares the build environment.
#   ./configure: Configures the build system.
#   make: Compiles the DSSP binary.
# Result: Builds the dssp executable.
#Verifies the DSSP installation and displays the version.
#Step 11: Calculate Secondary Structure - Run `martinize2` with Secondary Structure
martinize2 -f 181L_clean.pdb -o t4l_only.top -x t4l_cg.pdb -p backbone -ff martini3001 -ss CCHHHHHHHHHCCEEEEEECTTSCEEEETTEEEESSSCHHHHHHHHHHHHTSCCTTBCCHHHHHHHHHHHHHHHHHHHHHCTTTHHHHHHSCHHHHHHHHHHHHHHHHHHHHTCHHHHHHHHTTCHHHHHHHHHSSHHHHHSHHHHHHHHHHHHHSSSGGGC
# Purpose: Coarse-grains the protein structure with secondary structure information.  


#Step 12: Generate the MARTINI simulation box
# The system needs to be placed inside a simulation box. The box should:
# Have enough space (1 nm or more) between the protein and the box edges to prevent interactions with periodic images.
# Be at least twice the cut-off distance used in simulations (Martini uses a default cut-off of ~1.1 nm).
#Use the following command to create a dodecahedron box with 1.0 nm padding:
gmx editconf -f t4l_cg.pdb -d 1.0 -bt dodecahedron -o t4l_cg.gro
# -f t4l_cg.pdb: Input coarse-grained structure file.
# -d 1.0: Adds 1.0 nm padding between the protein and box edges.
# -bt dodecahedron: Creates a dodecahedral simulation box.
# -o t4l_cg.gro: Outputs the structure in the generated box.


#step 13: Preprocess the Minimization Input Files
Use grompp to preprocess the system, combining the structure, topology, and parameter files into a binary .tpr file:
# Copy and paste the following files into file directory:
#  -minimization.mdp
#  -martini_v3.0.0.itp
#     - In the topology file, replace "martini.itp" with "martini_v3.0.0.itp".


# step 14: Perform the Minimization
# Run the minimization using the .tpr file:
gmx mdrun -deffnm minimization-vac -v
# -deffnm minimization-vac: Specifies the output files will have the prefix minimization-vac.
# -v: Enables verbose mode to show progress in the terminal.
# Resulting Files
#After running the minimization, you should have the following:
    -1. minimization-vac.gro: Minimized structure in vacuum.
    -2. minimization-vac.log: Log file with details of the minimization.
    -3. minimization-vac.trr: Trajectory file of the minimization.
    -4. minimization-vac.edr: Energy file with information on potential energy.
# Key Points to Remember
# 1. Why Minimize in Vacuum?
    -It ensures that the protein structure is free of steric clashes before solvation and further simulations.

    -Vacuum minimization is faster since it doesn't include water or ions.
2. How to Ensure Correct Topology?
    -Always verify that the topology file includes the appropriate martini_v3.0.0.itp file.
#Box Dimensions:
    -Box size should be sufficiently large to prevent interactions between periodic images.
#Customizing Parameters:
    -Adjust minimization.mdp settings (e.g., nsteps) as needed for your system.
##############


# Step 15: Solvate the System
# Use `gmx solvate` to add water molecules around the protein structure, ensuring the box is sufficiently large to prevent 
# periodic boundary artifacts.
    -cp minimization-vac.gro: Input file containing the minimized protein structure in vacuum.
    -cs water.gro: Equilibrated water box file for MARTINI (this can be downloaded from the tutorial or template folder).
    -radius 0.21: Minimum van der Waals distance between solute (protein) and solvent (water molecules) to avoid overlaps or clashes.
    -o solvated.gro: Output file containing the protein surrounded by water molecules.
    
gmx solvate -cp minimization-vac.gro -cs water.gro -radius 0.21 -o solvated.gro

# Resulting Files:
    -1. solvated.gro: Protein structure surrounded by coarse-grained water beads.
    -2. t4l_only.top: Automatically updated to include the added water molecules.

# Key Points to Remember:
# - Ensure the water box (water.gro) is compatible with the MARTINI force field.
# - Use a sufficiently large `-radius` value to avoid steric clashes.

# Step 16: Preprocess for Ion Addition
# Prepare the system to add ions by creating a .tpr file that combines the structure, topology, and parameter files.
# -p t4l_only.top: Topology file of the solvated system.
# -f ions.mdp: Parameter file for ion addition (you can use a generic parameter file or adapt the minimization.mdp file).
# -c solvated.gro: Input file containing the solvated system.
# -o ions.tpr: Output file for ion addition preparation.
gmx grompp -p t4l_only.top -f ions.mdp -c solvated.gro -o ions.tpr

# Resulting Files:
# 1. ions.tpr: Preprocessed file for adding ions.

# Key Points to Remember:
# - Ensure the topology file (t4l_only.top) includes MARTINI ion topology files.

# Step 17: Neutralize the System
# Use `gmx genion` to add neutralizing ions to balance the system's charge.
# -s ions.tpr: Input file prepared for ion addition.
# -o solvated_ions.gro: Output file containing the neutralized system.
# -p t4l_only.top: Topology file, which will be updated to include the added ions.
# -pname NA: Specifies the name of the positive ion (e.g., Na+).
# -nname CL: Specifies the name of the negative ion (e.g., Cl−).
# -neutral: Automatically calculates and adds ions to neutralize the system's net charge (+8 in this case).
gmx genion -s ions.tpr -o solvated_ions.gro -p t4l_only.top -pname NA -nname CL -neutral

# Resulting Files:
# 1. solvated_ions.gro: System with neutralized charge.
# 2. Updated t4l_only.top: Topology file includes water molecules and neutralizing ions.

# Key Points to Remember:
# - Ensure the MARTINI ion topology files are included in t4l_only.top.
# - Verify that the system's net charge is now 0.

# Step 18: Add Physiological Ionic Strength
# To represent physiological conditions, add additional NaCl ions to achieve a concentration of 0.15 M.
# Note: Each MARTINI water bead represents 4 water molecules, so adjust the target salt concentration accordingly.
# -conc 0.15: Specifies the salt concentration in mol/L.
# -neutral: Ensures the system remains neutral while adding extra ions.
gmx genion -s ions.tpr -o solvated_salt.gro -p t4l_only.top -pname NA -nname CL -neutral -conc 0.15

# Resulting Files:
# 1. solvated_salt.gro: Neutralized system with added NaCl ions to achieve 0.15 M ionic strength.
# 2. Updated t4l_only.top: Topology file includes water molecules and ions.

# Key Points to Remember:
# - Physiological salt concentration (0.15 M NaCl) mimics realistic conditions.
# - Adjust for MARTINI water representation (1 bead = 4 water molecules).