#!/usr/bin/env python3
"""Generate project.pbxproj for StyleMate Xcode project."""

# Source files: (varname, path, filename)
sources = [
    ("APP", "StyleMateApp.swift", "StyleMateApp.swift"),
    ("CV", "Views/ContentView.swift", "ContentView.swift"),
    ("UP", "Models/UserProfile.swift", "UserProfile.swift"),
    ("WI", "Models/WardrobeItem.swift", "WardrobeItem.swift"),
    ("OS", "Models/OutfitSuggestion.swift", "OutfitSuggestion.swift"),
    ("AE", "Models/AstrologyEngine.swift", "AstrologyEngine.swift"),
    ("WS", "Models/WeatherService.swift", "WeatherService.swift"),
    ("PVM", "ViewModels/ProfileViewModel.swift", "ProfileViewModel.swift"),
    ("WVM", "ViewModels/WardrobeViewModel.swift", "WardrobeViewModel.swift"),
    ("OVM", "ViewModels/OutfitViewModel.swift", "OutfitViewModel.swift"),
    ("OBV", "Views/Onboarding/OnboardingView.swift", "OnboardingView.swift"),
    ("HV", "Views/Home/HomeView.swift", "HomeView.swift"),
    ("SFC", "Views/Home/ShareFitCard.swift", "ShareFitCard.swift"),
    ("CNV", "Views/Home/ConfettiView.swift", "ConfettiView.swift"),
    ("BSV", "Views/Home/BodySilhouetteView.swift", "BodySilhouetteView.swift"),
    ("LCB", "Views/Home/LuckyColorBanner.swift", "LuckyColorBanner.swift"),
    ("WV", "Views/Wardrobe/WardrobeView.swift", "WardrobeView.swift"),
    ("AIV", "Views/Wardrobe/AddItemView.swift", "AddItemView.swift"),
    ("EIV", "Views/Wardrobe/EditItemView.swift", "EditItemView.swift"),
    ("WPV", "Views/Planner/WeeklyPlannerView.swift", "WeeklyPlannerView.swift"),
    ("HIV", "Views/History/HistoryView.swift", "HistoryView.swift"),
    ("PSV", "Views/Profile/ProfileSettingsView.swift", "ProfileSettingsView.swift"),
    ("BPU", "Views/Profile/BodyPhotoUploadView.swift", "BodyPhotoUploadView.swift"),
    ("BPC", "Views/Home/BodyPhotoCarouselView.swift", "BodyPhotoCarouselView.swift"),
    ("A3D", "Views/Avatar/Avatar3DSceneView.swift", "Avatar3DSceneView.swift"),
    ("ATV", "Views/Avatar/AvatarTabView.swift", "AvatarTabView.swift"),
    ("OBD", "Views/Avatar/OutfitBoardView.swift", "OutfitBoardView.swift"),
    ("SSV", "Views/Avatar/ShoppingSuggestionsView.swift", "ShoppingSuggestionsView.swift"),
    ("CE", "Helpers/ColorExtensions.swift", "ColorExtensions.swift"),
    ("DE", "Helpers/DateExtensions.swift", "DateExtensions.swift"),
    ("ICE", "Helpers/ImageColorExtractor.swift", "ImageColorExtractor.swift"),
    ("CLX", "Helpers/ClothingExtractor.swift", "ClothingExtractor.swift"),
    ("AIM", "Helpers/AppIconManager.swift", "AppIconManager.swift"),
    ("SME", "Helpers/StyleMatchEngine.swift", "StyleMatchEngine.swift"),
]

def uid(n):
    return f"AA{n:022X}"

# Assign UIDs
file_refs = {}
build_files = {}
for i, (var, path, fname) in enumerate(sources):
    file_refs[var] = uid(0x100 + i)
    build_files[var] = uid(0x200 + i)

# Resources
FR_ASSETS = uid(0x300)
FR_PREVIEW = uid(0x301)
BF_ASSETS = uid(0x302)
BF_PREVIEW = uid(0x303)
FR_PRODUCT = uid(0x304)

# Groups
GR_ROOT = uid(0x400)
GR_PRODUCTS = uid(0x401)
GR_MAIN = uid(0x402)
GR_MODELS = uid(0x403)
GR_VMS = uid(0x404)
GR_VIEWS = uid(0x405)
GR_ONBOARD = uid(0x406)
GR_HOME = uid(0x407)
GR_WARDROBE = uid(0x408)
GR_PLANNER = uid(0x409)
GR_HISTORY = uid(0x40A)
GR_HELPERS = uid(0x40B)
GR_PROFILE = uid(0x40D)
GR_PREVIEW = uid(0x40C)
GR_AVATAR = uid(0x40E)

# Build phases
BP_SOURCES = uid(0x500)
BP_FRAMEWORKS = uid(0x501)
BP_RESOURCES = uid(0x502)

# Target & Project
TGT = uid(0x600)
PRJ = uid(0x601)

# Configs
CL_PRJ = uid(0x700)
CL_TGT = uid(0x701)
CF_PRJ_DBG = uid(0x702)
CF_PRJ_REL = uid(0x703)
CF_TGT_DBG = uid(0x704)
CF_TGT_REL = uid(0x705)

lines = []
def w(s=""): lines.append(s)

w("// !$*UTF8*$!")
w("{")
w("\tarchiveVersion = 1;")
w("\tclasses = {")
w("\t};")
w("\tobjectVersion = 56;")
w("\tobjects = {")
w("")

# PBXBuildFile
w("/* Begin PBXBuildFile section */")
for var, path, fname in sources:
    w(f"\t\t{build_files[var]} /* {fname} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_refs[var]}; }};")
w(f"\t\t{BF_ASSETS} /* Assets.xcassets in Resources */ = {{isa = PBXBuildFile; fileRef = {FR_ASSETS}; }};")
w(f"\t\t{BF_PREVIEW} /* Preview Assets.xcassets in Resources */ = {{isa = PBXBuildFile; fileRef = {FR_PREVIEW}; }};")
w("/* End PBXBuildFile section */")
w("")

# PBXFileReference
w("/* Begin PBXFileReference section */")
w(f'\t\t{FR_PRODUCT} /* StyleMate.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = StyleMate.app; sourceTree = BUILT_PRODUCTS_DIR; }};')
for var, path, fname in sources:
    w(f'\t\t{file_refs[var]} /* {fname} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {fname}; sourceTree = "<group>"; }};')
w(f'\t\t{FR_ASSETS} /* Assets.xcassets */ = {{isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = "<group>"; }};')
w(f'\t\t{FR_PREVIEW} /* Preview Assets.xcassets */ = {{isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = "Preview Assets.xcassets"; sourceTree = "<group>"; }};')
w("/* End PBXFileReference section */")
w("")

# PBXFrameworksBuildPhase
w("/* Begin PBXFrameworksBuildPhase section */")
w(f"\t\t{BP_FRAMEWORKS} = {{")
w("\t\t\tisa = PBXFrameworksBuildPhase;")
w("\t\t\tbuildActionMask = 2147483647;")
w("\t\t\tfiles = (")
w("\t\t\t);")
w("\t\t\trunOnlyForDeploymentPostprocessing = 0;")
w("\t\t};")
w("/* End PBXFrameworksBuildPhase section */")
w("")

# PBXGroup
w("/* Begin PBXGroup section */")

# Root
w(f"\t\t{GR_ROOT} = {{")
w("\t\t\tisa = PBXGroup;")
w("\t\t\tchildren = (")
w(f"\t\t\t\t{GR_MAIN} /* StyleMate */,")
w(f"\t\t\t\t{GR_PRODUCTS} /* Products */,")
w("\t\t\t);")
w('\t\t\tsourceTree = "<group>";')
w("\t\t};")

# Products
w(f"\t\t{GR_PRODUCTS} = {{")
w("\t\t\tisa = PBXGroup;")
w(f"\t\t\tchildren = (")
w(f"\t\t\t\t{FR_PRODUCT} /* StyleMate.app */,")
w("\t\t\t);")
w("\t\t\tname = Products;")
w('\t\t\tsourceTree = "<group>";')
w("\t\t};")

# Main group
w(f"\t\t{GR_MAIN} = {{")
w("\t\t\tisa = PBXGroup;")
w("\t\t\tchildren = (")
w(f"\t\t\t\t{file_refs['APP']} /* StyleMateApp.swift */,")
w(f"\t\t\t\t{GR_MODELS} /* Models */,")
w(f"\t\t\t\t{GR_VMS} /* ViewModels */,")
w(f"\t\t\t\t{GR_VIEWS} /* Views */,")
w(f"\t\t\t\t{GR_HELPERS} /* Helpers */,")
w(f"\t\t\t\t{FR_ASSETS} /* Assets.xcassets */,")
w(f"\t\t\t\t{GR_PREVIEW} /* Preview Content */,")
w("\t\t\t);")
w("\t\t\tpath = StyleMate;")
w('\t\t\tsourceTree = "<group>";')
w("\t\t};")

# Models
models = ["UP", "WI", "OS", "AE", "WS"]
w(f"\t\t{GR_MODELS} = {{")
w("\t\t\tisa = PBXGroup;")
w("\t\t\tchildren = (")
for v in models:
    fname = [s[2] for s in sources if s[0]==v][0]
    w(f"\t\t\t\t{file_refs[v]} /* {fname} */,")
w("\t\t\t);")
w("\t\t\tpath = Models;")
w('\t\t\tsourceTree = "<group>";')
w("\t\t};")

# ViewModels
vms = ["PVM", "WVM", "OVM"]
w(f"\t\t{GR_VMS} = {{")
w("\t\t\tisa = PBXGroup;")
w("\t\t\tchildren = (")
for v in vms:
    fname = [s[2] for s in sources if s[0]==v][0]
    w(f"\t\t\t\t{file_refs[v]} /* {fname} */,")
w("\t\t\t);")
w("\t\t\tpath = ViewModels;")
w('\t\t\tsourceTree = "<group>";')
w("\t\t};")

# Views
w(f"\t\t{GR_VIEWS} = {{")
w("\t\t\tisa = PBXGroup;")
w("\t\t\tchildren = (")
w(f"\t\t\t\t{file_refs['CV']} /* ContentView.swift */,")
w(f"\t\t\t\t{GR_ONBOARD} /* Onboarding */,")
w(f"\t\t\t\t{GR_HOME} /* Home */,")
w(f"\t\t\t\t{GR_WARDROBE} /* Wardrobe */,")
w(f"\t\t\t\t{GR_PLANNER} /* Planner */,")
w(f"\t\t\t\t{GR_HISTORY} /* History */,")
w(f"\t\t\t\t{GR_PROFILE} /* Profile */,")
w(f"\t\t\t\t{GR_AVATAR} /* Avatar */,")
w("\t\t\t);")
w("\t\t\tpath = Views;")
w('\t\t\tsourceTree = "<group>";')
w("\t\t};")

# Sub-view groups
for gr, name, vars_list in [
    (GR_ONBOARD, "Onboarding", ["OBV"]),
    (GR_HOME, "Home", ["HV", "SFC", "CNV", "BSV", "LCB", "BPC"]),
    (GR_WARDROBE, "Wardrobe", ["WV", "AIV", "EIV"]),
    (GR_PLANNER, "Planner", ["WPV"]),
    (GR_HISTORY, "History", ["HIV"]),
    (GR_PROFILE, "Profile", ["PSV", "BPU"]),
    (GR_AVATAR, "Avatar", ["A3D", "ATV", "OBD", "SSV"]),
]:
    w(f"\t\t{gr} = {{")
    w("\t\t\tisa = PBXGroup;")
    w("\t\t\tchildren = (")
    for v in vars_list:
        fname = [s[2] for s in sources if s[0]==v][0]
        w(f"\t\t\t\t{file_refs[v]} /* {fname} */,")
    w("\t\t\t);")
    w(f"\t\t\tpath = {name};")
    w('\t\t\tsourceTree = "<group>";')
    w("\t\t};")

# Helpers
helpers = ["CE", "DE", "ICE", "CLX", "AIM", "SME"]
w(f"\t\t{GR_HELPERS} = {{")
w("\t\t\tisa = PBXGroup;")
w("\t\t\tchildren = (")
for v in helpers:
    fname = [s[2] for s in sources if s[0]==v][0]
    w(f"\t\t\t\t{file_refs[v]} /* {fname} */,")
w("\t\t\t);")
w("\t\t\tpath = Helpers;")
w('\t\t\tsourceTree = "<group>";')
w("\t\t};")

# Preview Content
w(f"\t\t{GR_PREVIEW} = {{")
w("\t\t\tisa = PBXGroup;")
w(f"\t\t\tchildren = (")
w(f"\t\t\t\t{FR_PREVIEW} /* Preview Assets.xcassets */,")
w("\t\t\t);")
w('\t\t\tpath = "Preview Content";')
w('\t\t\tsourceTree = "<group>";')
w("\t\t};")

w("/* End PBXGroup section */")
w("")

# PBXNativeTarget
w("/* Begin PBXNativeTarget section */")
w(f"\t\t{TGT} = {{")
w("\t\t\tisa = PBXNativeTarget;")
w(f"\t\t\tbuildConfigurationList = {CL_TGT};")
w("\t\t\tbuildPhases = (")
w(f"\t\t\t\t{BP_SOURCES},")
w(f"\t\t\t\t{BP_FRAMEWORKS},")
w(f"\t\t\t\t{BP_RESOURCES},")
w("\t\t\t);")
w("\t\t\tbuildRules = (")
w("\t\t\t);")
w("\t\t\tdependencies = (")
w("\t\t\t);")
w("\t\t\tname = StyleMate;")
w("\t\t\tproductName = StyleMate;")
w(f"\t\t\tproductReference = {FR_PRODUCT};")
w('\t\t\tproductType = "com.apple.product-type.application";')
w("\t\t};")
w("/* End PBXNativeTarget section */")
w("")

# PBXProject
w("/* Begin PBXProject section */")
w(f"\t\t{PRJ} = {{")
w("\t\t\tisa = PBXProject;")
w("\t\t\tattributes = {")
w("\t\t\t\tBuildIndependentTargetsInParallel = 1;")
w("\t\t\t\tLastSwiftUpdateCheck = 1500;")
w("\t\t\t\tLastUpgradeCheck = 1500;")
w("\t\t\t\tTargetAttributes = {")
w(f"\t\t\t\t\t{TGT} = {{")
w("\t\t\t\t\t\tCreatedOnToolsVersion = 15.0;")
w("\t\t\t\t\t};")
w("\t\t\t\t};")
w("\t\t\t};")
w(f"\t\t\tbuildConfigurationList = {CL_PRJ};")
w('\t\t\tcompatibilityVersion = "Xcode 14.0";')
w("\t\t\tdevelopmentRegion = en;")
w("\t\t\thasScannedForEncodings = 0;")
w("\t\t\tknownRegions = (")
w("\t\t\t\ten,")
w("\t\t\t\tBase,")
w("\t\t\t);")
w(f"\t\t\tmainGroup = {GR_ROOT};")
w(f"\t\t\tproductRefGroup = {GR_PRODUCTS};")
w('\t\t\tprojectDirPath = "";')
w('\t\t\tprojectRoot = "";')
w("\t\t\ttargets = (")
w(f"\t\t\t\t{TGT},")
w("\t\t\t);")
w("\t\t};")
w("/* End PBXProject section */")
w("")

# PBXResourcesBuildPhase
w("/* Begin PBXResourcesBuildPhase section */")
w(f"\t\t{BP_RESOURCES} = {{")
w("\t\t\tisa = PBXResourcesBuildPhase;")
w("\t\t\tbuildActionMask = 2147483647;")
w("\t\t\tfiles = (")
w(f"\t\t\t\t{BF_PREVIEW} /* Preview Assets.xcassets in Resources */,")
w(f"\t\t\t\t{BF_ASSETS} /* Assets.xcassets in Resources */,")
w("\t\t\t);")
w("\t\t\trunOnlyForDeploymentPostprocessing = 0;")
w("\t\t};")
w("/* End PBXResourcesBuildPhase section */")
w("")

# PBXSourcesBuildPhase
w("/* Begin PBXSourcesBuildPhase section */")
w(f"\t\t{BP_SOURCES} = {{")
w("\t\t\tisa = PBXSourcesBuildPhase;")
w("\t\t\tbuildActionMask = 2147483647;")
w("\t\t\tfiles = (")
for var, path, fname in sources:
    w(f"\t\t\t\t{build_files[var]} /* {fname} in Sources */,")
w("\t\t\t);")
w("\t\t\trunOnlyForDeploymentPostprocessing = 0;")
w("\t\t};")
w("/* End PBXSourcesBuildPhase section */")
w("")

# Build configurations - shared settings
common_debug = """ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					"DEBUG=1",
					"$(inherited)",
				);
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 16.0;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				MTL_FAST_MATH = YES;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = iphoneos;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = "DEBUG $(inherited)";
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";"""

common_release = """ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 16.0;
				MTL_ENABLE_DEBUG_INFO = NO;
				MTL_FAST_MATH = YES;
				SDKROOT = iphoneos;
				SWIFT_COMPILATION_MODE = wholemodule;
				VALIDATE_PRODUCT = YES;"""

target_settings = """ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_ASSET_PATHS = "\\"StyleMate/Preview Content\\"";
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.vaibhav.StyleMate;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";"""

w("/* Begin XCBuildConfiguration section */")
for cfg_id, name, settings in [
    (CF_PRJ_DBG, "Debug", common_debug),
    (CF_PRJ_REL, "Release", common_release),
]:
    w(f"\t\t{cfg_id} /* {name} */ = {{")
    w("\t\t\tisa = XCBuildConfiguration;")
    w("\t\t\tbuildSettings = {")
    w(f"\t\t\t\t{settings}")
    w("\t\t\t};")
    w(f"\t\t\tname = {name};")
    w("\t\t};")

for cfg_id, name in [(CF_TGT_DBG, "Debug"), (CF_TGT_REL, "Release")]:
    w(f"\t\t{cfg_id} /* {name} */ = {{")
    w("\t\t\tisa = XCBuildConfiguration;")
    w("\t\t\tbuildSettings = {")
    w(f"\t\t\t\t{target_settings}")
    w("\t\t\t};")
    w(f"\t\t\tname = {name};")
    w("\t\t};")

w("/* End XCBuildConfiguration section */")
w("")

# XCConfigurationList
w("/* Begin XCConfigurationList section */")
w(f"\t\t{CL_PRJ} = {{")
w("\t\t\tisa = XCConfigurationList;")
w("\t\t\tbuildConfigurations = (")
w(f"\t\t\t\t{CF_PRJ_DBG},")
w(f"\t\t\t\t{CF_PRJ_REL},")
w("\t\t\t);")
w("\t\t\tdefaultConfigurationIsVisible = 0;")
w("\t\t\tdefaultConfigurationName = Release;")
w("\t\t};")
w(f"\t\t{CL_TGT} = {{")
w("\t\t\tisa = XCConfigurationList;")
w("\t\t\tbuildConfigurations = (")
w(f"\t\t\t\t{CF_TGT_DBG},")
w(f"\t\t\t\t{CF_TGT_REL},")
w("\t\t\t);")
w("\t\t\tdefaultConfigurationIsVisible = 0;")
w("\t\t\tdefaultConfigurationName = Release;")
w("\t\t};")
w("/* End XCConfigurationList section */")

w("\t};")
w(f"\trootObject = {PRJ};")
w("}")
w("")

with open("/Users/vaibhavgupta/Desktop/StyleMate/StyleMate.xcodeproj/project.pbxproj", "w") as f:
    f.write("\n".join(lines))

print("project.pbxproj generated successfully!")
