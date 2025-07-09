# `dotnet build`

## Building the same solution with dotnet CLI and MSBuild

### SQL projects

Two part solution:

#### 1) Don't build the SQL project by marking the SQL Project as `Build=False` in the Solution

You can edit your `.sln` file manually to **exclude your SQL project from the build** without removing it from the solution.

##### 🔧 Steps:

1. Open your `.sln` file in a text editor.
2. Find the section like this (where `YourDbProjectName` is the `.sqlproj`):
   ```
   Project("{GUID}") = "YourDbProjectName", "path\to\YourDbProjectName.sqlproj", "{PROJECT_GUID}"
       ...
   EndProject
   ```

3. Below that, find the `GlobalSection(ProjectConfigurationPlatforms)` section.
4. Change the entries for `Build.**` to **not build** the DB project. For example:
   ```ini
   {PROJECT_GUID}.Debug|Any CPU.ActiveCfg = Debug|Any CPU
   {PROJECT_GUID}.Debug|Any CPU.Build.0 = Debug|Any CPU  ← REMOVE THIS LINE
   ```

   By removing the `.Build.0` line, `dotnet build` will skip that project.

> ✅ This keeps the project in your solution for reference, but ensures it's not built with `dotnet build`.

#### 2) Build the SQL project separately

```powershell
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
$msbuild = & $vswhere -latest -requires Microsoft.Component.MSBuild -find MSBuild\**\Bin\MSBuild.exe
& $msbuild "path\to\your\project.sqlproj"
```

## Building a project that references a SQL project with both `dotnet build` and Visual Studio

### 🎯 Goal
You want:
- ✅ SQL project to **build** when opening both projects in Visual Studio.
- 🚫 SQL project to **not build** when using `dotnet build` on the test project from command line.

### 🧩 Solution: Use `SkipProjectBuild` Metadata on the SQL Project Reference

In your **test project's** `.csproj` file, modify the reference to the SQL project like this:

```xml
<ItemGroup>
  <ProjectReference Include="..\YourSqlProject\YourSqlProject.csproj">
    <SkipProjectBuild Condition="'$(BuildingInsideVisualStudio)' != 'true'">true</SkipProjectBuild>
  </ProjectReference>
</ItemGroup>
```

- ✅ When running in **Visual Studio**, the condition is false → SQL project **does build**.
- 🚫 When running `dotnet build` outside Visual Studio, the condition is true → SQL project **is skipped**.
- ✅ All other referenced projects (without the `SkipProjectBuild` tag) still build normally.

This gives you granular control without affecting your overall project structure. Smooth!

### 🧪 Bonus Tip
If your test project doesn't need the compiled output of the SQL project to run tests, you might also consider:
- Making the SQL project a **ProjectReference** with `ReferenceOutputAssembly="false"` if you only need it for deployment scripts or similar.
- Or turning the SQL project into a **non-referenced artifact**—like copying `.dacpac` or scripts as content rather than a formal dependency.


## If you get `error MSB4278` from the when compiling the sqlproj-file



Let’s tweak it to check **both** conditions:

### ✅ Updated Import (safe for CLI and Visual Studio)

```xml
<Import Project="$(MSBuildExtensionsPath)\Microsoft\VisualStudio\v$(VisualStudioVersion)\SSDT\Microsoft.Data.Tools.Schema.SqlTasks.targets"
        Condition=" '$(BuildingInsideVisualStudio)' == 'true' " />
```

or if you already have a condition for the `*.targets` file:
```xml
<Import 
  Project="$(MSBuildExtensionsPath)\Microsoft\VisualStudio\v$(VisualStudioVersion)\SSDT\Microsoft.Data.Tools.Schema.SqlTasks.targets"
  Condition="'$(BuildingInsideVisualStudio)' == 'true' and '$(SQLDBExtensionsRefPath)' == ''" />
```

### 🔍 Why This Works
- ✅ Only imports the SSDT targets if you're building **inside Visual Studio**.
- ✅ Prevents `dotnet build` from trying (and failing) to load Visual Studio-specific files.
- 💥 Eliminates the CLI error you’re seeing while preserving full functionality in the IDE.

You’re threading this needle with precision—really nice work getting this dialed in. Want a quick checklist to validate this setup end-to-end?